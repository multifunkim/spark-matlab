function [pipeline,opt] = spark_pipeline_fmri_kmap(files_in,opt)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Seting up default arguments %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% FILES_IN
files_in = sub_check_format(files_in); % check the format of FILES_IN
[fmri_c,label] = niak_fmri2cell(files_in); % Convert FILES_IN into a cell of string form
[path_f,name_f,ext_f] = niak_fileparts(fmri_c{1}); % Get the extension of outputs

%% OPT
list_fields    = {'flag_session', 'flag_test' ,'flag_verbose'  ,'flag_rand'  ,'tune'     ,'granularity'  ,'folder_in'    , 'folder_out' , 'folder_logs' ,'folder_kmdl'    ,'folder_global_dictionary','folder_kmap' ,'folder_tseries_boot','psom'    };
list_defaults  = {true          , false       , true           ,false        ,struct()   ,'cleanup'      , NaN           , NaN          , ''            , ''              ,''                        ,''            ,''                   ,struct()  };
opt = psom_struct_defaults(opt,list_fields,list_defaults);
opt.psom.path_logs = [opt.folder_out 'logs' filesep];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% The pipeline starts here %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
pipeline = struct();

%% Build individual pipelines
if opt.flag_verbose
    fprintf('Generating pipeline of SPARK for individual data :\n')
end
list_subject = fieldnames(files_in);

for num_s = 1:length(list_subject)
    subject = list_subject{num_s};
    if opt.flag_verbose
        t1 = clock;
        fprintf('    Adding %s : ',subject);
    end
    opt_ind = sub_tune(opt,subject); % Tune the pipeline parameters for this subject    
    pipeline_ind = spark_pipeline_fmri_kmap_ind(files_in.(subject),opt_ind);

    %% aggregate jobs
    switch opt.granularity
       case 'max'
           pipeline = psom_merge_pipeline(pipeline,pipeline_ind);
       case 'cleanup'
           pipeline = psom_merge_pipeline(pipeline,psom_bundle_cleanup(pipeline_ind,['clean_' subject]));
       case 'subject'
           [pipeline.(['preproc_' subject]),pipeline.(['clean_' subject])] = psom_pipeline2job(pipeline_ind,[opt.psom.path_logs subject]);
       otherwise
           error('%s is not a supported level of granularity for the pipeline',opt.granularity)
    end     
               
    if opt.flag_verbose        
        fprintf('%1.2f sec\n',etime(clock,t1));
    end
end


%% Run the pipeline
if ~opt.flag_test
	% The fileds 'dir' and 'data' below may cause errors 
	% because they are considered as non existant inputs to the jobs.
	% Temporary solution: create the non-existant input directories.
	% Permanent solution: do not put those fields because they are not useful, use fileparts.
	jobNames = fieldnames(pipeline);

	jobFilter = 'kmdl_boot';
	validJobs = jobNames(strncmp(jobNames, jobFilter, numel(jobFilter)));
	for k = 1:numel(validJobs)
		if isfield(pipeline.(validJobs{k}).files_in, 'dir')
			private_mkdir(pipeline.(validJobs{k}).files_in.dir);
		end
	end

	jobFilter = 'kmdl_Gx_';
	validJobs = jobNames(strncmp(jobNames, jobFilter, numel(jobFilter)));
	for k = 1:numel(validJobs)
		if isfield(pipeline.(validJobs{k}).files_in, 'data')
			private_mkdir(pipeline.(validJobs{k}).files_in.data);
		end
	end
	clear jobNames jobFilter validJobs

    psom_run_pipeline(pipeline,opt.psom);
end




%%%%%%%%%%%%%%%%%%
%% SUBFUNCTIONS %%
%%%%%%%%%%%%%%%%%%

function files_in = sub_check_format(files_in)
%% Checking that FILES_IN is in the correct format

if ~isstruct(files_in)
    
    error('FILES_IN should be a structure!')
    
else
    
    list_subject = fieldnames(files_in);
    for num_s = 1:length(list_subject)
        
        subject = list_subject{num_s};
        
        if ~isstruct(files_in.(subject))
            error('FILES_IN.%s should be a structure!',upper(subject));
        end
        
        if ~isfield(files_in.(subject),'fmri')
            error('I could not find the field FILES_IN.%s.FMRI!',upper(subject));
        end
        
        list_session = fieldnames(files_in.(subject).fmri);
        
        for num_c = 1:length(list_session)
            session = list_session{num_c};
            if ~iscellstr(files_in.(subject).fmri.(session))&&~isstruct(files_in.(subject).fmri.(session))
                error('FILES_IN.%s.fmri.%s should be a structure or a cell of strings!',upper(subject),upper(session));
            end
        end
        
       
        if ~isfield(files_in.(subject),'component_to_keep')
            files_in.(subject).component_to_keep = 'gb_niak_omitted';
        end
    end
    
end



function opt_ind = sub_tune(opt,subject)
%% Tune the pre-processing parameters for a subject (or group of subjects)
opt_ind = opt;
if isfield(opt.tune,'subject')
    for num_e = 1:length(opt.tune)
        if ~isfield(opt.tune(num_e),'type')||isempty(opt.tune(num_e).type)
            opt.tune(num_e).type = 'exact';
        end
        switch opt.tune(num_e).type
            case 'exact'
                if strcmp(opt.tune(num_e).subject,subject)
                    opt_ind = psom_merge_pipeline(opt_ind,opt.tune(num_e).param);
                end
            case 'regexp'
                if any(regexp(subject,opt.tune(num_e).subject))
                    opt_ind = psom_merge_pipeline(opt_ind,opt.tune(num_e).param);
                end
        end
    end
end
opt_ind = rmfield(opt_ind,{'tune','flag_verbose','granularity','flag_rand'});
opt_ind.subject = subject;
opt_ind.flag_test = true;
