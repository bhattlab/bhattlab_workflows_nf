# Running a workflow

In order to run a nextflow workflow, you will need three to four things:
- the workflow (usually a `.nf` file)
- a `config` file for talking to the cluster
- a file with parameters
- (optional) other parameters supplied directly to the nextflow command


In principle, when using the workflows in this repository, you will not
have to worry about the workflow file or the `run.config` files. Those files
specify the order of processes and how to talk to a slurm cluster and 
generally do not change across different projects.

## Setup

The most important file for you to edit is the `params.yml` file that contains
all the information that you need to adjust to your specific system. See
the [Setup](./setup.md) documentation for guidance on how to edit this file.

## Execution

Once you have your input data and `params.yml` file ready, you can then run
the workflow like this:
```bash
module load java/18.0.2.1
module load nextflow/22.10.5

nextflow run </path/to/this/repo>/workflows/preprocessing.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file ./params.yml \
	-with-trace -with-report
```

## Second project 

If you want to run the same preprocessing then for a different project,
simply duplicate the `params.yml` file and adjust the `output` and `samples`
parameter and you can just run the same workflow on your new data like this:
```bash
module load java/18.0.2.1
module load nextflow/22.10.5

nextflow run </path/to/this/repo>/workflows/preprocessing.nf \
	-c </path/to/this/repo>/config/run.config \
	-params-file ./params_new_project.yml \
	-with-trace -with-report
```

Please note that you can run only a single nextflow workflow at the same time
from the same directory. Nextflow will lock the current working directory (
from which you called `nextflow run` and no other workflow can be started 
while the other one is still running).


## Troubleshooting

It might happen that you run into an unforeseen problem and one of the processes
that nextflow is managing for you errors out. If so, nextflow will tell you
which process ran into an error and where you can find the corresponding logs.
Each process gets assigned a working directory with a unique hash in 
the `work` folder.
For example, the output of nextflow might look like this:
```bash
executor >  slurm (79)
[54/a2ce3b] process > binning_prep (BINNING_PREP ... [100%] 12 of 12 ✔
[f3/33b63b] process > metabat (METABAT on D04_T2)    [100%] 12 of 12 ✔
[46/dbf5b9] process > maxbin (MAXBIN on D04_T2)      [100%] 12 of 12 ✔
[95/193f4e] process > concoct (CONCOCT on D04_T1)    [ 91%] 11 of 12
[e3/9f45b7] process > dastool (DASTool on D04_T1)    [ 91%] 11 of 12, failed:...
[e1/f745aa] process > checkm (CheckM on D02_T2)      [100%] 10 of 10
[b9/09b2d2] process > gtdbtk (GTDB-tk on D02_T2)     [100%] 10 of 10
[e3/9f45b7] NOTE: Process `dastool (DASTool on D04_T1)` terminated with an error exit status (1) -- Execution is retried (1)
```

It makes sense to check out the log files in this folder to figure out what is
going on:
```bash
cd ./work/e3/9f45b7<tab>
ls -l

```
Please note that the actual folder name is much longer, but you can just use
autocomplete to find the correct folder for the process that errored out.





