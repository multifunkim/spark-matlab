function [files_in, files_out,opt] = spark_run_fmri_tseries_boot(files_in,files_out, opt)

if opt.flag_test == 1
    return
end

%% Load ROI Time Series
fprintf(['Reading fMRI data... \n']);
[hdr,vol] = niak_read_vol(files_in); % read fMRI data

%% Load Brain mask
fprintf(['Reading brain mask... \n']);
[hdr_mask,mask] = niak_read_vol(opt.mask); % read brain mask
tseries = niak_vol2tseries(vol,mask>0);
tseries = niak_normalize_tseries(tseries,'mean_var');

%% Bootstrap
for num_s = 1:opt.nb_samps
    fprintf([num2str(num_s) '-th bootstrap resampling... \n']);
    if num_s==1
        tseries_boot=tseries;
    else
        tseries_boot= niak_bootstrap_tseries(tseries,opt.bootstrap);
    end 
    % Save resampled data
    save([opt.folder_out 'tseries_boot' num2str(num_s) '_' opt.label.name '.mat'], 'tseries_boot');
    
end

