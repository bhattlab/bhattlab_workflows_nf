# Bhattlab metagenomics workflows [nf]
Computational workflows for metagenomics tasks, packaged with Nextflow and 
Singularity.

This repository is modeled on the [Snakemake workflows from the 
Bhattlab](https://github.com/bhattlab/bhattlab_workflows), where you might 
find more workflows. 

### Table of contents

 1. [Setup](documentation/setup.md)
 2. [Running a workflow](documentation/running.md)
 3. Available workflows
    - [**Preprocessing** metagenomic data](documentation/preprocessing.md)
    - [Metagenomic **Assembly**](documentation/assembly.md)
    - [Metagenomic **Binning**](documentation/binning.md)
    - [Metagenomic **Classification**](documentation/classification.md)
    - [**Sourmash** read comparison](documentation/sourmash.md)
    - [**Viral** contig prediction](manual/viral.md) 

### Quickstart

If you're in the Bhatt lab and working on SCG, you should clone this 
repository to your folder:
```bash
git clone git@github.com:bhattlab/bhattlab_workflows_nf.git
```
You can then run a workflow like this:

```bash
module load nextflow/24.04.4

nextflow run </path/to/this/repo>/workflows/preprocessing.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report -resume
```

Note that you might have to modify the `params.yml` 
file according to your project. There is a template in the [config 
folder](config/params.yml), as a start.  
Other users will need to change these options (see [Running a 
workflow](documentation/running.md))


**Important**  
Once everything is done and ran correctly, you should delete all the 
unnecessary temporary files and save us space on SCG! 
Just remove the `work` folder from wherever you called the nextflow command: 
```
rm -r ./work
```
You can also remove the `.nextflow` folder, which contains metadata and cache 
from the run. 
```
rm -rf .nextflow 
```


## Question?

Please feel free to check out the documentation folder. Maybe your question 
has already been answered.
Otherwise, you can open an 
[issue](https://github.com/jakob-wirbel/bhattlab_workflows_nf/issues/new) 
in this repository. Please make sure to thorougly describe your problem 
and to attach any relevant output and log files.
