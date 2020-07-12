# SPARK

[SPARK](https://www.sciencedirect.com/science/article/pii/S1053811916002548) (SParsity-based Analysis of Reliable K-hubness) is a MATLAB-based (GNU Octave) toolbox for functional MRI analysis dedicated to the reliable estimation of overlapping functional network structure from individual fMRI (Lee et al., Neuroimage, 2016). It is a voxel-wise multivariate analysis of BOLD fMRI data based on the [data driven sparse GLM](http://ieeexplore.ieee.org/document/5659483). The main contributions of SPARK involves: i) it proposes a novel measure of hubness, "k-hubness", by counting the number of functional networks spatiaotemporally overlapping in each voxel, ii) it handles multicollinearity of functional networks based on the sparse GLM, without forcing a strong assumption of independence as in Independent Component Analysis (ICA) or voxel-to-single-network assignments as in hierarchical clustering. Statistical reproducibility of the estimation of hubs of overlapping networks in each individual is achieved by a bootstrap resampling based strategy. Briefly, a large number of bootstrap surrogates (e.g. B=200 resampled datasets with equal dimensions as the original fMRI data; time-by-voxel) are generated using the Circular Block Bootstrap (Bellec et al., 2010) and sparse dictionary learning (e.g. a modified K-SVD) is applied for each surrogate in parallel. The output of B processes involve B sets of a data-driven dictionary (temporal characteristics of networks) and the corresponding sparse coefficient matrix (spatial maps of networks). The spatial maps are then collected and clustered to find the most reproducible patterns of networks across the resampled datasets. Then the maps are averaged in each cluster. After a series of denoising, SPARK provides a set of individually consistent resting state networks and a map of k-hubness. This method is fully data-driven, and parameters of the sparse dictionary learning process (the total number of networks and the sparsity levels for each voxel) are automatically estimated using minimum description criterion.

------------

SPARK has been built upon Neuroimaging Analysis Kit ([NIAK](https://github.com/SIMEXP/niak)), which is a public library of modules and pipelines for fMRI processing with Octave or Matlab(r) that can run in parallel either locally or in a supercomputing environment. Matlab codes of SPARK were developed and written by Kangjoo Lee (kangjoo.lee@mail.mcgill.ca). 

SPARK is currently available on Github: https://github.com/multifunkim/spark-matlab (matlab version), https://github.com/multifunkim/spark-hpc (hpc version). Ali Obai (ali.obai.b.k@gmail.com), a PhD student in Grova Lab mainly contributed to the public release of SPARK. We are also working on including SPARK within CBRAIN platform (also available on https://github.com/multifunkim/spark-cbrain).

------------

# Citation

If you use this library for your publications, please cite it as:

Kangjoo Lee, Jean-Marc Lina, Jean Gotman and Christophe Grova, “SPARK: Sparsity-based analysis of reliable k-hubness and overlapping network structure in brain functional connectivity”, Neuroimage, vol. 134, pp. 434–449, April 2016

Additional reference:

Kangjoo Lee, Hui Ming Khoo, Jean-Marc Lina, François Dubeau, Jean Gotman and Christophe Grova, “Disruption, emergence and lateralization of brain network hubs in mesial temporal lobe epilepsy”, Neuroimage: Clinical, vol. 20, pp. 71–84, June 2018
