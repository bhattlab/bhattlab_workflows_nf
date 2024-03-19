# Setup

Before you can run the workflows without any errors, you will need to make some
preparations. Those mostly consist of downloading databases for the tools that
are part of the workflow.

The second part of preparing to run a workflow consists of adjusting the 
`params.yml` file which holds all the important information for your system.

The workflows here have been run on a high-performance computing cluster 
using the [Slurm](https://slurm.schedmd.com/overview.html) scheduler. If you 
are running these workflows on a different system, you might have to adjust 
the [`run.config`](config/run.config) file as well.

### Table of contents

 0. Installing `nextflow`
 1. Databases and host reference genomes
 	- Human reference genome
 	- MetaPhlAn4 database
 	- mOTUs3 database
 	- CheckM database
 	- VIBRANT database
 	- geNomad database
 2. Adjusting the `params.yml` file
