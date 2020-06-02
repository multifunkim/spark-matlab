# SPARK

[SPARK](https://www.sciencedirect.com/science/article/pii/S1053811916002548) is a MATLAB-based (GNU Octave) toolbox for functional MRI analysis dedicated to the reliable estimation of overlapping functional network structure from individual fMRI. It is a voxel-wise multivariate analysis of a set of 3D+t BOLD contrast images, based on sparse dictionary learning for the [data driven sparse GLM](http://ieeexplore.ieee.org/document/5659483). It further achieves statistical reproducibility of the estimation of individual network structure by a bootstrap resampling based strategy. This method is fully data-driven, and provides an automatic estimation of the number (K) and combination of overlapping networks based on L0-norm sparisty and minimum description criterion.

------------

SPARK has been built upon Neuroimaging Analysis Kit ([NIAK](https://github.com/SIMEXP/niak)), which is a public library of modules and pipelines for fMRI processing with Octave or Matlab(r) that can run in parallel either locally or in a supercomputing environment.

------------

# Citation

If you use this library for your publications, please cite it as:

Kangjoo Lee, Jean-Marc Lina, Jean Gotman and Christophe Grova, “SPARK: Sparsity-based analysis of reliable k-hubness and overlapping network structure in brain functional connectivity”, Neuroimage, vol. 134, pp. 434–449, April 2016

Additional reference:

Kangjoo Lee, Hui Ming Khoo, Jean-Marc Lina, François Dubeau, Jean Gotman and Christophe Grova, “Disruption, emergence and lateralization of brain network hubs in mesial temporal lobe epilepsy”, Neuroimage: Clinical, vol. 20, pp. 71–84, June 2018
