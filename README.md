# SPARK

[SPARK](https://www.sciencedirect.com/science/article/pii/S1053811916002548) (SParsity-based Analysis of Reliable K-hubness) is a MATLAB-based (GNU Octave) toolbox for functional MRI analysis dedicated to the reliable estimation of overlapping functional network structure from individual fMRI (Lee et al., Neuroimage, 2016).  

SPARK provides a set of individually consistent resting state networks and a map of k-hubness. This method is fully data-driven, voxel-wise multivariate analysis of BOLD fMRI data based on the [data driven sparse GLM](http://ieeexplore.ieee.org/document/5659483). Parameters of the sparse dictionary learning process (the total number of networks and the sparsity levels for each voxel) are automatically estimated using minimum description criterion. SPARK proposes a novel measure of hubness, "k-hubness", by counting the number of functional networks spatiaotemporally overlapping in each voxel. Statistical reproducibility of the estimation of hubs of overlapping networks in each individual is ensured using a bootstrap resampling based strategy, as follows.

* Step 1: A large number of bootstrap surrogates (e.g. B=200 resampled datasets with equal dimensions as the original fMRI data; time-by-voxel) are generated using the Circular Block Bootstrap (Bellec et al., 2010).
* Step 2: Sparse dictionary learning (e.g. a modified K-SVD) is applied for each surrogate in parallel. The outputs of B processes involve B sets of a data-driven dictionary (temporal characteristics of networks) and the corresponding sparse coefficient matrix (spatial maps of networks). 
* Step 3: The spatial maps are collected and clustered to find the most reproducible patterns of networks across the resampled datasets. The maps are then averaged in each cluster. 
* Step 4: Denoising: statistical reproducibility across B bootstrap resamples
* Step 5 (Optional): Denoising of physiological artifect atoms by visual inspections.
* Step 6: Computation of k-hubness for each voxel.

------------

SPARK has been built upon Neuroimaging Analysis Kit ([NIAK](https://github.com/SIMEXP/niak)), which is a public library of modules and pipelines for fMRI processing with Octave or Matlab(r) that can run in parallel either locally or in a supercomputing environment. Matlab codes of SPARK were developed and written by Kangjoo Lee (kangjoo.lee@mail.mcgill.ca). 

SPARK is currently available on GitHub: 
 - https://github.com/multifunkim/spark-matlab (MATLAB version)
 - https://github.com/multifunkim/spark-hpc (HPC version)
 - https://github.com/multifunkim/spark-cbrain (CBRAIN plugin)

------------

# Citation

If you use this library for your publications, please cite it as:

Kangjoo Lee, Jean-Marc Lina, Jean Gotman and Christophe Grova, “SPARK: Sparsity-based analysis of reliable k-hubness and overlapping network structure in brain functional connectivity”, Neuroimage, vol. 134, pp. 434–449, April 2016

Additional reference:

Kangjoo Lee, Hui Ming Khoo, Jean-Marc Lina, François Dubeau, Jean Gotman and Christophe Grova, “Disruption, emergence and lateralization of brain network hubs in mesial temporal lobe epilepsy”, Neuroimage: Clinical, vol. 20, pp. 71–84, June 2018
