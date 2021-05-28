# arousal-rsfMRIpupil-hub

* `SPARK_fMRI_pupillometry.m` performs a four-step analysis: 

https://github.com/Kangjoo/arousal-rsfMRIpupil-hub/blob/c418b16da19dc68bfe6034fd7a00ca5f2d9ea3c5/SPARK_fMRI_pupillometry.m#L1-L9

* Other scripts to implement the remainings of the SPARK analysis, such as the parallel implementation of the sparse dictionary learning, spatial K-means clustering, background noise removal, and k-hubness estimation, can be found and adapted from [SPARK](https://github.com/multifunkim/spark-matlab).   

* `SPARK_HDI.m` computes the hub disruption index (HDI) to compare k-hubness estimated from fMRI data in two arousal states, e.g., high and low arousal.

For further questions please raise an issue [here](https://github.com/Kangjoo/Arousal_RSfMRI_Hub/issues)

------------
# Requirements

* SParsity-based Analysis of Reliable K-hubness ([SPARK](https://github.com/multifunkim/spark-matlab))

* Neuroimaging Analysis Kit ([NIAK](https://github.com/SIMEXP/niak)) - preferred version: niak-boss-0.13.0.  

* [SPM8](https://www.fil.ion.ucl.ac.uk/spm/software/spm8/) or [SPM12](https://www.fil.ion.ucl.ac.uk/spm/software/spm12/) is required to process pupillometry data.

------------
# Citation

If you use this library for your publications, please cite it as:

