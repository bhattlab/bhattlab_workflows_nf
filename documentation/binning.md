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

The assembly input should look like this:

```
sampleID,contigs
Sample_1,</path/to/assembly/>contigs_sample1.fa
Sample_2,</path/to/assembly/>contigs_sample2.fa
```

For the preprocessed reads input file, the input is the same as for 
the assembly workflow.
For paired-end short read data, it would look like this:

```
sampleID,forward,reverse,orphans
Sample_1,</path/to/reads/>reads_sample1_1.fq.gz,</path/to/reads/>reads_sample1_2.fq.gz,</path/to/reads/>reads_sample1_orphans.fq.gz
Sample_2,</path/to/reads/>reads_sample2_1.fq.gz,</path/to/reads/>reads_sample2_2.fq.gz,</path/to/reads/>reads_sample2_orphans.fq.gz
```

For single-end short read data or long-read data, the input would be:
```
sampleID,reads
Sample_1,</path/to/reads/>cleaned_reads_1.fq.gz
Sample_2,</path/to/reads/>cleaned_reads_2.fq.gz
```
and you again would have to set the `single_end` or `long_read`
parameters to `true`.


### Custom input

If you used the [preprocessing]('./preprocessing.md') and 
[assembly]('./assembly.md') workflows, you will not 
have to provide the sheet with the preprocessed reads and the assemblies. 
The output of these workflows will be found by the binning workflow.

If you want to run binning only on some samples or on samples 
processed in a different way, you can either specify the `preprocessed_reads` 
and `assemblies` paramter in the `params.yml` file or you can 
supply them when calling the nextflow process like this:  
```bash
nextflow run </path/to/this/repo>/workflows/binning.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report --preprocessed_reads ./preprocessed_reads.csv \
	--assemblies ./assemblies.csv
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
