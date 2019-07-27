function [files_in,files_out,opt] = spark_run_fmri_kmap(files_in,files_out,opt)

%% If the test flag is true, stop here !
if opt.flag_test == 1
    return
end


%% Thresholding the average coefficient matrix
load(files_in.data,'GX')
finalX       = GX;
imageSizeX=size(finalX,1);
imageSizeY=size(finalX,2);
test_dist=reshape(finalX,imageSizeX*imageSizeY,1);
[x,n]=hist(test_dist,100);
gmean=n(find(x == max(x)));
for w=1:1000
    subidx=randi([1 length(test_dist)],0.95*length(test_dist),1);
    stds(w)=std(test_dist(subidx));
end;clear w
final_std=mean(stds);
X = norminv([opt.pvalue/2  1-opt.pvalue/2],gmean,final_std);
Xmask = abs(finalX) > max(abs(X));
thrfinalX= abs(finalX) .* Xmask;

%% remove atoms with small number of voxels
for i=1:size(thrfinalX,1)
   t(i)=nnz(thrfinalX(i,:));
end
thrfinalX(find(t<30),:)=[]; 

%% compute k-hubness
for ind=1: size(thrfinalX,2)
    opt_k(ind)=nnz(thrfinalX(:,ind));
    weighted_opt_k(ind)=sum(thrfinalX(:,ind));
end

%% k-map generation
[hdr,vol_mask] = niak_read_vol(files_in.mask);
vol_mask = round(vol_mask);

k_map = niak_tseries2vol(opt_k,vol_mask);
hdr.file_name = files_out.kmaps;
niak_write_vol(hdr,k_map);

weighted_k_map = niak_tseries2vol(weighted_opt_k,vol_mask);
files_out.weighted_kmaps = [opt.folder_out 'weighted_kmap_' opt.label.name '.mnc.gz'];
hdr.file_name = files_out.weighted_kmaps;
niak_write_vol(hdr,weighted_k_map);

% Save output files
if ~strcmp(files_out.kmap_all_mat,'gb_niak_omitted')
    hdr.file_name = '';
    save(files_out.kmap_all_mat, 'k_map','hdr','opt_k');
end


%% final atom maps 
for i=1:size(thrfinalX,1)
    atom=thrfinalX(i,:);
    atom_map{i} = niak_tseries2vol(atom,vol_mask);
    hdr.file_name = [opt.folder_out,'atom' num2str(i) '_',opt.label.name '.mnc.gz'];
    niak_write_vol(hdr,atom_map{i});
end


% Save output files
if ~strcmp(files_out.atoms_all_mat,'gb_niak_omitted')
    hdr.file_name = '';
    save(files_out.atoms_all_mat, 'atom_map','hdr','opt_k');
end



%% Save all
save([opt.folder_out 'kmdl_nfGx_' opt.label.name '_p' num2str(opt.pvalue) '.mat']);
fprintf('%20s\n','...Completed')

