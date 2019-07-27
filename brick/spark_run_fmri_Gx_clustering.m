function [files_in, files_out,opt] = spark_run_fmri_Gx_clustering(files_in,files_out, opt)

if opt.flag_test == 1
    return
end


%% Initialization
Con_X        = [];
param   =opt.ksvd.param;

%% Dictionary Concatenation
for num_b = 1:opt.nb_samps
    fprintf(['Load a spatial map trained from ' num2str(num_b) 'th data... \n']);
    load([files_in.data 'kmdl_boot' num2str(num_b) '_' opt.label.name '.mat'],'output');
    X=output.CoefMatrix;
    if param.preserveDCAtom == 1
        Con_X = vertcat(Con_X, X(2:end,:));
    else
        Con_X = vertcat(Con_X, X);
    end
    clear Dictionary
end


%% Stable Spatial Maps (Clustering)
fprintf(['Generate consistent netework maps... \n']);
opt_tmp.nb_classes     = round(size(Con_X,1)/opt.nb_samps);%param.K;
opt_tmp.flag_bisecting = false;
opt_tmp.flag_verbose   = false;
[part,gi,i_intra,i_inter] = niak_kmeans_clustering(Con_X',opt_tmp);
GX=gi';


%% Save output results
save(files_out, 'Con_X','param','GX');



%% Delete intermediate files
for num_b = 2:opt.nb_samps
    
    delete([opt.clean 'tseries_boot' num2str(num_b) '_' opt.label.name '.mat']);
    delete([files_in.data 'kmdl_boot' num2str(num_b) '_' opt.label.name '.mat']);
    
end
fprintf('Intermediate files were deleted.\n')



fprintf('Done.\n')
