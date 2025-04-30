# Viral annotation

The viral annotation pipeline identified putative phages in
the assembled contigs.

Our pipeline runs the following processes:

- VIRBANT
- geNomad
- CheckV

## Setup

As for every of these workflows, you will have to edit the `params.yml` file
to specify the output location, database locations, and parameters (see the
[General setup](./setup.md) page). Of importance for the 
assembly workflow is:

- VIRBANT database location
- geNomad database location
- CheckV database location


Then, you can run the workflow like this:
```bash
nextflow run </path/to/this/repo>/workflows/viral_annotation.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report
```

## Input

The input to this pipeline is the location of the assemblies. Therefore,
it is independent of the sequencing technology used to create these
assemblies.
The input file should look like this:
```
sampleID,contigs
Sample_1,</path/to/assembly/>contigs_sample1.fa
Sample_2,</path/to/assembly/>contigs_sample2.fa
```

### Custom input

If you used the [assembly]('./assembly.md') workflow, you will not 
have to provide the sheet with the contigs , as this
pipeline will find the location of the contigs in the `outdir`. 

If you want to run assembly only on some samples or on samples 
processed in a different way, you can either specify the `assemblies` 
parameter in the `params.yml` file or you can supply it when calling the 
nextflow process like this:  
```bash
nextflow run </path/to/this/repo>/workflows/viral_annotation.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file params.yml \
	-with-trace -with-report --assemblies ./assemblies.csv
```

## Output

This script will create the following outputs:

- `viruses`: Main output folder, containing
	- `genomad`: Folder containing the genomad output
	- `vibrant`: Folder containing the vibrant output
	- `checkv`: Folder containing the checkV results for both genomad and vibrant
- `versions_viral_annotation.yml`: The versions for each of the tools using in the
viral annotation pipeline