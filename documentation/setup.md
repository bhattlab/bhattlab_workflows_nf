# Setup

Before you can run the workflows without any errors, you will need to make some
preparations. Those mostly consist of downloading databases for the tools that
are part of the workflow.

The second part of preparing to run a workflow consists of adjusting the 
`params.yml` file which holds all the important information for your system.
To run multiple workflows (for example, first preprocessing, then assembly,
lastly binning), you need to edit the `params.yml` file only once and then you
can re-use it for all of the workflows. 

The workflows here have been run on a high-performance computing cluster 
using the [Slurm](https://slurm.schedmd.com/overview.html) scheduler. If you 
are running these workflows on a different system, you might have to adjust 
the [`run.config`](../config/run.config) file as well.

### Table of contents

 0. Installing `nextflow`
 1. Databases and host reference genomes
 	- [Human] reference genome
 	- MetaPhlAn4 database
 	- mOTUs3 database
 	- CheckM database
 	- GTDB-tk database
 	- Bakta database
 	- VIBRANT database
 	- geNomad database
 2. Adjusting the `params.yml` file

## Installing Nextflow

On SCG, nextflow is already installed and can be loaded via `module load`. 
Please note that you need the right version of java as well for it to work. 
Therefore, add the following lines to your script:

```bash
module load nextflow/24.04.4
```

If you are running these workflows on another system, good luck! You can find
a good documentation for installing Nextflow 
[here](https://www.nextflow.io/docs/latest/getstarted.html#installation).

## Databases and host reference genomes

### Host reference genomes

You will need a host reference genome on your file system so that you can 
remove all reads matching to the host genome from your sample, since we are
interested in the bacteria, not the host genome. We map reads to the host 
genome with the `bwa` algorithm, so you will need to index the host 
genome before being able to use the workflow.

You can download for example the human reference genome from the
[UCSC Genome Browser website](https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/):
```bash
cd <your-reference-genome-location>
wget https://hgdownload.soe.ucsc.edu/goldenPath/hg38/bigZips/hg38.fa.gz
gunzip hg38.fa.gz
```

Now, you can index the genome with `bwa`. However, if you want to use the 
singularity container that we use for the workflow (because you might not have
`bwa` installed on your system), you can do so like that by using the `--bind`
command when running the singularity container:
```bash
cd <your-reference-genome-location>
singularity shell --bind ./:/mnt docker://ghcr.io/jakob-wirbel/micromamba-focal-preprocessing:latest
cd /mnt
bwa index hg38.fa
```

### MetaPhlAn4 database

We also need to download the MetaPhlAn4 database, again using the already
prepared singularity container:

```bash
cd <your-metaphlan-database-location>
singularity shell --bind ./:/mnt docker://ghcr.io/jakob-wirbel/micromamba-focal-classification:latest
cd /mnt
metaphlan --install --bowtie2db ./
```

### mOTUs3 database

The mOTU tool needs a custom database of marker genes. Unfortunately, you 
cannot download the database through the tool as of now, but maybe it will be
available as a feature in the future (see 
[this issue](https://github.com/motu-tool/mOTUs/issues/109)). Instead, we can
download and configure the database manually:

```bash
cd <your-motus-database-location>
wget https://zenodo.org/record/5140350/files/db_mOTU_v3.0.1.tar.gz
md5sum db_mOTU_v3.0.1.tar.gz
# expected output: f4fd09fad9b311fb4f21383f6101bfc3
# if you do not see this output, something went wrong and you need to download
# the database again!
tar -zxvf db_mOTU_v3.0.1.tar.gz
```

The version file in the Zenodo repository is not really up-to-date with the
version numbering system of mOTUs, so you will have to adjust it manually:
```bash
cd db_mOTU
sed -i 's/2.6.0/3.0.3/g' db_mOTU_versions
```

### CheckM database

You will also need to download the database for checkM. This is available through 
Zenodo as well and can be downloaded and extracted like that:
```bash

cd <your-checkm-database-location>
wget https://zenodo.org/record/7401545/files/checkm_data_2015_01_16.tar.gz
md5sum checkm_data_2015_01_16.tar.gz
# expected output: 631012fa598c43fdeb88c619ad282c4d
# if you do not see this output, something went wrong and you need to download
# the database again!
tar -zxvf checkm_data_2015_01_16.tar.gz
rm checkm_data_2015_01_16.tar.gz
```

### GTDB-tk database

The documentation for GTDB-tk can be found 
[here]().
The current version of this workflow uses the version `v2.3.2`, so you will
need the following database:

```bash
cd <your-gtdbtk-database-location>
wget https://data.gtdb.ecogenomic.org/releases/release214/214.0/auxillary_files/gtdbtk_r214_data.tar.gz
md5sum gtdbtk_r214_data.tar.gz
# expected output: 630745840850c532546996b22da14c27
# if you do not see this output, something went wrong and you need to download
# the database again!
tar -xvzf gtdbtk_r214_data.tar.gz
rm gtdbtk_r214_data.tar.gz
```

### Bakta database

The bakta database is hosted on Zenodo. You can check out the 
[Bakta Github](https://github.com/oschwengers/bakta?tab=readme-ov-file#database)
to find more information about the database. The current version
of these workflows use `bakta v1.8.2`, so you will need the 
`v_5.0` of the database:

```bash
cd <your-bakta-database-location>
wget https://zenodo.org/records/7669534/files/db.tar.gz
md5sum db.tar.gz
# expected output: 3200136a0a32b3c33d1cb348ab6b87de 
# if you do not see this output, something went wrong and you need to download
# the database again!
tar -zxvf db.tar.gz
rm db.tar.gz
```

Additionally, you will have to run the `armfinder-update`, because otherwise
the workflow will fail. You can use the singularity container for that:

```bash
cd <your-bakta-database-location>
cd db
singularity shell --bind ./:/mnt docker://ghcr.io/jakob-wirbel/micromamba-focal-longread:latest
cd /mnt
amrfinder_update --force_update --database ./amrfinderplus-db/
```

### VIBRANT database

To download the database for VIRBANT, we can again use the already
prepared singularity container:

```bash
cd <your-vibrant-database-location>
singularity shell --bind ./:/mnt docker://ghcr.io/jakob-wirbel/micromamba-focal-virus:latest
cd /mnt
download-db.sh .
```

### geNomad database

We also need to download the geNomad database, again using the already
prepared singularity container:

```bash
cd <your-genomad-database-location>
singularity shell --bind ./:/mnt docker://ghcr.io/jakob-wirbel/micromamba-focal-genomad:latest
cd /mnt
genomad download-database .
```

## Adjusting the `params.yml` file

The `params.yml` is **THE** place where information are stored about your
specific workflow. For every project, it is good to have a different 
`params.yml` file, but you can use it for multiple workflows.

Make a copy of the `config/params.yml` file in this repository and edit it,
for example using `nano`.

```bash
cd <your-project-location>
cp <bhattlab_workflows_nf-location>/config/params.yml ./params_project_x.yml
nano ./params_project_x.yml
```

Adjust the parameters in the file to those fitting your system/project. 
The most important parameter is the `outdir` parameter as it controls, 
where all the results will end up on your filesystem. The other parameters are
mostly the location for databases or tool-specific parameters that you can 
adjust to control the behaviour of the tool.
