function [files_in, files_out,opt] = spark_run_fmri_kmdl(files_in,files_out, opt)

if opt.flag_test == 1
    return
end

%% Load ROI Time Series
filename=[files_in.dir 'tseries_boot' num2str(opt.nb_boot) '_' opt.label.name '.mat'];
load(filename,'tseries_boot');
load(opt.init, 'param');
Tseries=tseries_boot;

%% Initialize parameters
param.InitializationMethod ='GivenMatrix';
param.L=param.initk;
param.K=param.net_scale;

tmp = Tseries;
tmp(:,all(tmp==0,1))=[];
rperm=randperm(size(tmp,2));
param.initialDictionary=tmp(:,rperm(1:param.K));


%% modified K-SVD of Bootstrapped Data
fprintf(['A varient of K-SVD on ' num2str(opt.nb_boot) 'th data...'])
fprintf('\n')
[Dictionary, output]       = spark_vKSVD(Tseries, param);


%% Save intermediate results

save([opt.folder_out 'kmdl_boot' num2str(opt.nb_boot) '_' opt.label.name '.mat'],'Tseries','Dictionary','output');
