# Assembly

The assembly pipeline will assemble [preprocessed reads](./preprocessing.md) 
into larger contigs, which can then be the basis for [binning](./binning.md).
Our pipeline does the following tasks:

- Assembly with [MEGAHIT](https://github.com/voutcn/megahit)
- Contiguity check with Quast
- Annotation of open reading frames with bakta


## Setup

As for every of these workflows, you will have to edit the `params.yml` file
to specify the output location, database locations, and parameters (see the
[General setup](./setup.md) page). Of importance for the 
preprocessing workflow is basically only the bakta database location.
Additionally, you will have to prepare the sample sheet (see below).

Then, you can run the workflow like this:
```bash
nextflow run </path/to/this/repo>/workflows/assembly.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report
```

## Input

The input for this process is a file containing the location of the 
preprocessed reads. This sample sheet file should look like this:  

```
sampleID,forward,reverse,orphans
Sample_1,</path/to/reads/>reads_sample1_1.fq.gz,</path/to/reads/>reads_sample1_2.fq.gz,</path/to/reads/>reads_sample1_orphans.fq.gz
Sample_2,</path/to/reads/>reads_sample2_1.fq.gz,</path/to/reads/>reads_sample2_2.fq.gz,</path/to/reads/>reads_sample2_orphans.fq.gz
```

If you used the [preprocessing]('./preprocessing.md') workflow, you will not 
have to provide the sheet with the preprocessed reads. One output of this 
workflow is a file specifying the location of the preprocessed reads in the
correct format and the assembly workflow will look for this file in the
specific `outdir` location.


However, if you want to run assembly only on some samples or on samples 
processed in a different way, you can either specify the `input` parameter in 
the `params.yml` file or you can supply it when calling the nextflow process 
like this:  
```bash
nextflow run </path/to/this/repo>/workflows/preprocessing.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report --input ./preprocessed_reads.csv
```

## Output

This script will create the following outputs:

- `assembly`: Main output folder, containing
	- `megahit`: Folder containing the megahit assemblies
	- `bakta`: Folder containing the output from bakta
	- `quast_report.tsv`: File tabulating the assembly quality for each sample
- `versions_assembly.yml`: The versions for each of the tools using in the
assembly pipeline
