# Binning

The binning pipeline will bin the contigs produced by the 
[assembly workflow](./assembly.md) into metagenome-assembled genomes (MAGs).
Our pipeline does the following tasks:

- Prepare the binning process by mapping the preprocessed reads back to the 
assemblies
- Binning with
	- MetaBAT
	- CONCOCT
	- Maxbin
- Combining the binning from the previous tools with DAStool
- Getting the quality of the DAStools bins with CheckM
- Taxonomically annotating the DAStools bins with GTDB-tk


## Setup

As for every of these workflows, you will have to edit the `params.yml` file
to specify the output location, database locations, and parameters (see the
[General setup](./setup.md) page). Of importance for the 
binning workflow is:
- the CheckM database location
- the GTDB-tk database location

Then, you can run the workflow like this:
```bash
nextflow run </path/to/this/repo>/workflows/binning.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report
```

## Input

The input for this process is a file containing the location of the 
preprocessed reads and another file containing the location of the assembly. 
The first input file should look like this:  

```
sampleID,forward,reverse,orphans
Sample_1,</path/to/reads/>reads_sample1_1.fq.gz,</path/to/reads/>reads_sample1_2.fq.gz,</path/to/reads/>reads_sample1_orphans.fq.gz
Sample_2,</path/to/reads/>reads_sample2_1.fq.gz,</path/to/reads/>reads_sample2_2.fq.gz,</path/to/reads/>reads_sample2_orphans.fq.gz
```

The second input file should look like this:
```
ampleID,contigs
Sample_1,</path/to/assembly/>contigs_sample1.fa
Sample_2,</path/to/assembly/>contigs_sample2.fa
```

If you used the [preprocessing]('./preprocessing.md') and 
[assembly]('./assembly.md') workflow, you will not have to provide both files
as input. Instead, the workflow will use the files already present in the
specified `outdir` location.


However, if you want to run binning only on some samples or on samples 
processed in a different way, you can either specify the `input` parameter 
(for the preprocessed reads) and the `input_assembly` parameter (for the
assembly) in the `params.yml` file or you can supply both when calling the 
nextflow process like this:  
```bash
nextflow run </path/to/this/repo>/workflows/binning.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report \
	--input ./preprocessed_reads.csv --input_assembly ./assemblies.csv
```

## Output

This script will create the following outputs:

- `binning`: Main output folder, containing
	- `checkm`: Folder containing the CheckM output files
	- `concoct`: Folder containing the CONCOCT bins
	- `dastool`: Folder containing the DAStool bins
	- `maxbin`: Folder containing the maxbin bins
	- `metabat`: Folder containing the metabat bins
	- `gtdb`: Folder containing the GTDB-tk output files
- `versions_binning.yml`: The versions for each of the tools using in the
binning pipeline

## Long reads

As for all the long read workflows, you will have to set the `long_reads` parameter
in the `params.yml` to `true`.

Additionally, the input file with the cleaned reads should only have two columns:

```
sampleID,reads
Sample_1,</path/to/reads/>cleaned_reads_1.fq.gz
Sample_2,</path/to/reads/>cleaned_reads_2.fq.gz
```

Lastly, you will have to supply the `samples` parameter when calling 
nextflow like this:

```bash
nextflow run </path/to/this/repo>/workflows/binning.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report \
	--samples ./cleaned_reads.csv --input_assembly ./assemblies.csv
```
