# Preprocessing

Preprocessing raw metagenomic data is necessary before any other application. 
Our preprocessing pipeline does the following tasks:

- [optional] Combine samples sequenced over multiple lanes
- Inital quality assessment
- Deduplicaiton of exactly matching sequencing reads
- Trimming of low quality bases and discarding of reads that fall below a
length limit
- Removal of reads that align against the host genome
- Final quality check


## Setup

As for every of these workflows, you will have to edit the `params.yml` file
to specify the output location, database locations, and parameters (see the
[General setup](./setup.md) page). Of importance for the 
preprocessing workflow is mostly the host genome and the parameters for `trim 
galore`.  
Additionally, you will have to prepare the sample sheet (see below).

Then, you can run the workflow like this:
```bash
nextflow run </path/to/this/repo>/workflows/preprocessing.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report
```

## Input

The input for this process is a file containing the location of the raw reads.
This sample sheet file should look like this:  

```
sampleID,forward,reverse
Sample_1,</path/to/raw/reads/>reads_xxx_1.fq.gz,</path/to/raw/reads/>reads_xxx_2.fq.gz
Sample_1,</path/to/raw/reads/>reads_xyz_1.fq.gz,</path/to/raw/reads/>reads_xyz_2.fq.gz
Sample_2,</path/to/raw/reads/>reads_zzz_1.fq.gz,</path/to/raw/reads/>reads_zzz_2.fq.gz
```

> **Important**
> The raw reads files need to end with
> `_1.fastq.gz` and `_2.fastq.gz`
> or with 
> `_1.fq.gz` and `_2.fq.gz`

In this case, the sample `Sample_1` has been sequenced over two lanes. The
workflow will combine these two lanes and then carry out the rest of the 
processes.

You can either specify the `samples` parameter in the `params.yml` file or you
can supply it when calling the nextflow process like this:  
```bash
nextflow run </path/to/this/repo>/workflows/preprocessing.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report --samples ./sample_sheet.csv
```

## Output

This script will create the following outputs:

- `preprocessed_reads`: Folder containing the preprocessed reads as fastq files
- `stats`: Folder containing:
	- `fastqc`: Folder with the results from fastqc
	- `multiqc`: Folder with the results from multiqc
	- `read_counts.tsv`: File tabulating the number (and fraction) of reads 
	that survive each preprocessing step
	- `count_plot.pdf`: Plot with the number of reads at each step
	- `preprocessed_reads.csv`: File with the location of all the preprocessed
	 reads. **This file is the input for downstream processes**
- `versions_preprocessing.yml`: The versions for each of the tools using in the
preprocessing pipeline

## Other considerations

If you have a larger project or the data coming in in several batches, the
workflow will detect if you have outputs in the specific output folder already
and will try to combine the previous results with the new results. So if you
are running a second batch with a different sample sheet, leave the rest of the
`params.yml` file like it was and the outputs for both batches should be 
combined.