# Classificaiton

The classificaiton pipeline will perform taxonomic classification
with MetaPhlAn and/or mOTUs.

### Short reads

Our pipeline does the following tasks:

- Classification with MetaPhlAn4
- Classification with mOTUs3

###  Long reads

Currently, this pipeline cannot be used with long reads. If you have
any ideas about tools that we should implement here, let us know!

## Setup

As for every of these workflows, you will have to edit the `params.yml` file
to specify the output location, database locations, and parameters (see the
[General setup](./setup.md) page). Of importance for the 
classification workflow is:

- metaphlan database
- motus database


Then, you can run the workflow like this:
```bash
nextflow run </path/to/this/repo>/workflows/classification.nf \
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

TBD

### Custom input

If you used the [preprocessing]('./preprocessing.md') workflow, you will not 
have to provide the sheet with the preprocessed reads. One output of this 
workflow is a file specifying the location of the preprocessed reads in the
correct format and the assembly workflow will look for this file in the
specific `outdir/stats` location.

If you want to taxonomic classification only on some samples or on samples 
processed in a different way, you can either specify the `preprocessed_reads` 
parameter in the `params.yml` file or you can supply it when calling the 
nextflow process like this:  
```bash
nextflow run </path/to/this/repo>/workflows/classification.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report --preprocessed_reads ./preprocessed_reads.csv
```

## Output

This script will create the following outputs:

- `classification`: Main output folder, containing
	- `motus_all.tsv`: Combine output from motus
	- `motus_all_gtdb.tsv`: Combine output from motus, using the GTDB taxonomy
	- `metaphlan_all.tsv`: Combine output from metaphlan
	- `metaphlan_all_gtdb.tsv`: Combine output from metaphlan, using the GTDB taxonomy
	- `motus`: Folder containing the output from motus
	- `metaphlan`: Folder containing the output from metaphlan
- `versions_classification.yml`: The versions for each of the tools using in the
classification pipeline
