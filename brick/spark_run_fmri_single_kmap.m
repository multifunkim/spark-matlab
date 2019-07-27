function [files_in, files_out,opt] = spark_run_fmri_single_kmap(files_in,files_out, opt)

if opt.flag_test == 1
    return
end


%% Load data
% Load ROI Time Series
fprintf(['Reading fMRI data... \n']);
[hdr,vol] = niak_read_vol(files_in); % read fMRI data

% Load Brain mask
fprintf(['Reading brain mask... \n']);
[hdr_mask,mask] = niak_read_vol(opt.mask); % read brain mask
tseries = niak_vol2tseries(vol,mask>0);
tseries = niak_normalize_tseries(tseries,'mean_var');
tseries=tseries(:,1:8:end);


param=opt.ksvd.param;
param.InitializationMethod ='GivenMatrix';
tmp = tseries;
tmp(:,all(tmp==0,1))=[];
param.numIteration = 10;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Network Scale estimation using sparse GLM (Lee et al, 2011, IEEE TMI)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf('%-50s ','Network Scale estimation...');
fprintf('\n')
MDL_scale=[];

for net_level=param.test_scale
    
    for sp_level=1:round(net_level/2)
        
        fprintf('%-50s ',['Testing scale = ' num2str(net_level) ', sparsity = ' num2str(sp_level)]);
        fprintf('\n')
        param.K=net_level;
        param.L=sp_level;
        
        %- Dictionary Initialization
        rperm=randperm(size(tmp,2));
        param.initialDictionary=tmp(:,rperm(1:param.K));
        
        %- KSVD
        [initDic, initout]       = spark_KSVD(tseries, param);
        % MDL estimation
        [mdl]=spark_MDL(tseries, initDic, initout, param);
        
        est=[net_level sp_level mdl];
        MDL_scale = vertcat(MDL_scale,est);
    end
end

%% Determine an optimal network scale and initialize sparsity level 
scale_mean=[];
for j=param.test_scale
    tmp=MDL_scale(:,1);
    scale_mean=vertcat(scale_mean,mean(MDL_scale(find(tmp == j),3)));
end
param.net_scale      = param.test_scale(find(scale_mean == min(scale_mean)));
param.kmax           = round(param.net_scale/2);
fprintf(['Network scale has been determined as ' num2str(param.net_scale) '... \n']);


tmp=MDL_scale(find(MDL_scale(:,1) == param.net_scale),:);
param.initk          = tmp(find(min(tmp(:,3)) ==tmp(:,3)),2);
fprintf(['Sparsty level has been initialized to ' num2str(param.initk) '... \n']);



clear initDic initout mdl sp_level net_level
param.numIteration   = opt.ksvd.param.numIteration;
%% Save intermediate results
save([opt.folder_out 'single_kmap_' opt.label.name '.mat']);
