function [pipeline,opt] = spark_pipeline_fmri_kmap_ind(files_in,opt)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seting up default arguments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% FILES_IN
files_in = sub_check_format(files_in); % Checking that FILES_IN is in the correct format

%% OPT
list_fields    = {'flag_session', 'flag_test' ,'flag_verbose'  ,'subject'  ,'folder_in'    , 'folder_out' , 'folder_logs' , 'folder_kmdl'  ,'folder_global_dictionary','folder_kmap' ,'folder_tseries_boot','psom'    };
list_defaults  = {true         , false       , true           , NaN       ,NaN            , NaN          , ''            , ''             ,''                        ,''            ,''                   ,struct()  };
opt = psom_struct_defaults(opt,list_fields,list_defaults);
subject = opt.subject;
opt.psom.path_logs = opt.folder_logs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The pipeline starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialization of the pipeline
% pipeline = struct();
pipeline = struct([]);
tmp.(subject) = files_in.fmri;
[fmri,label] = niak_fmri2cell(tmp);
% fmri_s = niak_fmri2struct(fmri,label);
[path_f,name_f,ext_f] = niak_fileparts(fmri{1});

opt.flag_verbose = 0;



%% Estimation of network scale and sparsity in the Sparse GLM:
if opt.flag_verbose
    t1 = clock;
    fprintf('Estimation of initial k in the Sparse GLM (');
end
for num_e = 1:length(fmri)
    clear job_in job_out job_opt
    job_in              = fmri{num_e};
    job_opt             = opt.folder_kmdl;
    job_opt.label       = label(num_e);
    job_opt.folder_in   = opt.folder_in;
    job_opt.folder_out  = [opt.folder_out 'single_kmap',filesep];
    if ~exist(job_opt.folder_out,'dir')
        mkdir(job_opt.folder_out);
    end
    job_out  = [job_opt.folder_out 'single_kmap_' label(num_e).name '.mat'];
    pipeline = psom_add_job(pipeline,['single_kmap_' label(num_e).name],'spark_run_fmri_single_kmap',job_in,job_out,job_opt);
end
if opt.flag_verbose
    fprintf('%1.2f sec) - ',etime(clock,t1));
end




%% Bootstrapping fMRI timeseries
if opt.flag_verbose
    t1 = clock;
    fprintf('Bootstrap resampling of data (');
end
for num_e = 1:length(fmri)
    clear job_in job_out job_opt
    job_in              = fmri{num_e};
    job_opt             = opt.folder_tseries_boot;
    job_opt.label       = label(num_e);
    job_opt.type='data';
    job_opt.folder_in   = opt.folder_in;
    job_opt.folder_out  = [opt.folder_out 'intermediate/tseries_boot',filesep];
    if ~exist(job_opt.folder_out,'dir')
        mkdir(job_opt.folder_out);
    end
    job_out  = [job_opt.folder_out 'tseries_boot' num2str(opt.folder_kmdl.nb_samps) '_' label(num_e).name '.mat'];
    pipeline = psom_add_job(pipeline,['tseries_boot_' label(num_e).name],'spark_run_fmri_tseries_boot',job_in,job_out,job_opt);
end
if opt.flag_verbose
    fprintf('%1.2f sec) - ',etime(clock,t1));
end



%% sparse dictionary learning (vK-SVD) on surrogates
if opt.flag_verbose
    t1 = clock;
    fprintf('1st level vK-SVD (');
end
for num_e = 1:length(fmri)
    clear job_in job_out job_opt 
    job_opt             = opt.folder_kmdl;
    job_opt.label       = label(num_e);
    job_opt.init        = pipeline.(['single_kmap_' label(num_e).name]).files_out;
    job_opt.folder_in   = opt.folder_in;
    job_opt.folder_out  = [opt.folder_out 'intermediate/kmdl/' label(num_e).name,filesep];
    if ~exist(job_opt.folder_out,'dir')
        mkdir(job_opt.folder_out);
    end
    job_in.check1   = pipeline.(['tseries_boot_' label(num_e).name]).files_out;
    job_in.check2    = pipeline.(['single_kmap_' label(num_e).name]).files_out;
    for num_b=1:opt.folder_kmdl.nb_samps
        job_in.dir=[opt.folder_out '/intermediate/tseries_boot/'];
        job_opt.nb_boot = num_b;
        job_out  = [job_opt.folder_out 'kmdl_boot' num2str(num_b) '_' label(num_e).name '.mat'];
        pipeline = psom_add_job(pipeline,['kmdl_boot' num2str(num_b) '_' label(num_e).name],'spark_run_fmri_kmdl',job_in,job_out,job_opt);
    end
    
end
if opt.flag_verbose
    fprintf('%1.2f sec) - ',etime(clock,t1));
end
 




%% Clustering for Spatial maps
if opt.flag_verbose
    t1 = clock;
    fprintf('Clustering for spatial maps (');
end
for num_e = 1:length(fmri)
    clear job_in job_out job_opt
    job_opt             = opt.folder_global_dictionary;
    job_opt.label       = label(num_e);
    job_opt.folder_in   = opt.folder_in;
    job_opt.folder_out  = [opt.folder_out 'intermediate/kmdl/' label(num_e).name,filesep];
    job_opt.clean=[opt.folder_out 'intermediate/tseries_boot/'];
    if ~exist(job_opt.folder_out,'dir')
        mkdir(job_opt.folder_out);
    end
    job_in.data    =[opt.folder_out 'intermediate/kmdl/' label(num_e).name,filesep];
    for num_b=1:opt.folder_kmdl.nb_samps
        job_in.(['str' num2str(num_b)])   = pipeline.(['kmdl_boot' num2str(num_b) '_' label(num_e).name]).files_out;
    end
    job_opt.nb_boot = opt.folder_kmdl.nb_samps;
    job_out  = [job_opt.folder_out 'kmdl_Gx_' label(num_e).name '.mat'];
    pipeline = psom_add_job(pipeline,['kmdl_Gx_' label(num_e).name],'spark_run_fmri_Gx_clustering',job_in,job_out,job_opt);
end
if opt.flag_verbose
    fprintf('%1.2f sec) - ',etime(clock,t1));
end




%% Generation of k-map and atom maps
if opt.flag_verbose
    t1 = clock;
    fprintf('Generating k-map and atom maps (');
end
for num_e = 1:length(fmri)
    clear job_in job_out job_opt
    job_in.data          = pipeline.(['kmdl_Gx_' label(num_e).name]).files_out;
    job_in.mask          = opt.folder_tseries_boot.mask;
    job_opt              = opt.folder_kmap;
    job_opt.label        = label(num_e);
    job_opt.folder_in    = opt.folder_in;
    job_opt.folder_out   = [opt.folder_out 'kmap_p' num2str(opt.folder_kmap.pvalue) ,filesep,label(num_e).name,filesep];
    if ~exist(job_opt.folder_out,'dir')
        mkdir(job_opt.folder_out);
    end
    job_opt.str          = pipeline.(['single_kmap_' label(num_e).name]).files_out;
    job_out.kmaps = [job_opt.folder_out 'kmap_' label(num_e).name '.mnc.gz'];
    job_out.kmap_all_mat = [job_opt.folder_out 'kmap_all_' label(num_e).name '.mat'];
    job_out.atoms_all_mat = [job_opt.folder_out 'atoms_all_' label(num_e).name '.mat'];
    pipeline = psom_add_job(pipeline,['nkmap_' label(num_e).name],'spark_run_fmri_kmap',job_in,job_out,job_opt);
end
if opt.flag_verbose
    fprintf('%1.2f sec) - ',etime(clock,t1));
end


%% Run the pipeline
if ~opt.flag_test
    psom_run_pipeline(pipeline,opt.psom);
end

%%%%%%%%%%%%%%%%%%
%% SUBFUNCTIONS %%
%%%%%%%%%%%%%%%%%%

function files_in = sub_check_format(files_in)
%% Check that FILES_IN is in a proper format

if ~isstruct(files_in)
    error('FILES_IN should be a struture!')
end
list_session = fieldnames(files_in.fmri);
nb_session   = length(list_session);
for num_c = 1:nb_session
    session = list_session{num_c};
    if ~iscellstr(files_in.fmri.(session))&&~isstruct(files_in.fmri.(session))
        error('files_in.fmri.%s should be a cell of strings or a structure!',session);
    end
end

if ~isfield(files_in,'component_to_keep')
    files_in.component_to_keep = 'gb_niak_omitted';
end

if ~isfield(files_in,'custom_confounds')
    files_in.custom_confounds = 'gb_niak_omitted';
end
