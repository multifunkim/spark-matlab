function [files_in, files_out,opt] = spark_run_fmri_tseries_boot(files_in,files_out, opt)

%% Step 1) This function loads 3D+t fMRI volume and extracts gray matter voxels defined by a binary mask.
%% Input files: a 3D+t fMRI file and a 3D mask file. Two files should have a same 3D dimension in space.
%% Step 2) Circular block bootstrap is applied to generate surrogates of the original fMRI time-courses. 
%% For a pre-defined number of surrogates B, the number of generated surrogates is B-1, to include the original fMRI data.

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

