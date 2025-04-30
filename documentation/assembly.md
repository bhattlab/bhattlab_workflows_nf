# Assembly

The assembly pipeline will assemble [preprocessed reads](./preprocessing.md) 
into larger contigs, which can then be the basis for [binning](./binning.md).


### Short reads

Our pipeline does the following tasks:

- Assembly with [MEGAHIT](https://github.com/voutcn/megahit)
- Contiguity check with Quast
- Annotation of open reading frames with bakta

###  Long reads

For long reads, assembly will be performed with Meta-Flye.

## Setup

As for every of these workflows, you will have to edit the `params.yml` file
to specify the output location, database locations, and parameters (see the
[General setup](./setup.md) page). Of importance for the 
assembly workflow is:

- bakta database location.


Then, you can run the workflow like this:
```bash
nextflow run </path/to/this/repo>/workflows/assembly.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report
```

## Input


### Paired-end short reads

The input for this process is a file containing the location of the 
preprocessed reads. This sample sheet file should look like this:  

```
sampleID,forward,reverse,orphans
Sample_1,</path/to/reads/>reads_sample1_1.fq.gz,</path/to/reads/>reads_sample1_2.fq.gz,</path/to/reads/>reads_sample1_orphans.fq.gz
Sample_2,</path/to/reads/>reads_sample2_1.fq.gz,</path/to/reads/>reads_sample2_2.fq.gz,</path/to/reads/>reads_sample2_orphans.fq.gz
```

### Single-end short reads 

For single-end short reads, the sample sheet should look like this:

```
sampleID,reads
Sample_1,</path/to/reads/>sample_1_cleaned.fq.gz
Sample_2,</path/to/reads/>sample_2_cleaned.fq.gz
```

Also, you need to set the `single_end` parameter in the `params.yml`
file to `true`.

### Long reads

For long reads, the sample sheet should look like this:

```
sampleID,reads
Sample_1,</path/to/reads/>sample_1_cleaned.fq.gz
Sample_2,</path/to/reads/>sample_2_cleaned.fq.gz
```

Also, you need to set the `long_reads` parameter in the `params.yml`
file to `true`.

### Custom input

If you used the [preprocessing]('./preprocessing.md') workflow, you will not 
have to provide the sheet with the preprocessed reads. One output of this 
workflow is a file specifying the location of the preprocessed reads in the
correct format and the assembly workflow will look for this file in the
specific `outdir/stats` location.

If you want to run assembly only on some samples or on samples 
processed in a different way, you can either specify the `preprocessed_reads` 
parameter in the `params.yml` file or you can supply it when calling the 
nextflow process like this:  
```bash
nextflow run </path/to/this/repo>/workflows/assembly.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report --preprocessed_reads ./preprocessed_reads.csv
```

## Output

This script will create the following outputs:

- `assembly`: Main output folder, containing
	- `megahit/flye`: Folder containing the megahit/flye assemblies
	- `bakta`: Folder containing the output from bakta
	- `quast_report.tsv`: File tabulating the assembly quality for each sample
- `versions_assembly.yml`: The versions for each of the tools using in the
assembly pipeline
