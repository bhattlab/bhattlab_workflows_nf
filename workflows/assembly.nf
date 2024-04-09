#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/* ASSEMBLY for short reads
 run megahit, bakta, and quast
*/

include { input_check } from '../modules/input/input_check'
include { megahit } from '../modules/assembly/megahit'
include { quast } from '../modules/assembly/quast'
include { combine_quast } from '../modules/assembly/quast'
include { bakta } from '../modules/assembly/bakta'

/* ASSEMBLY for long reads
 run flye, bakta, and quast
*/
include { input_raw_lr } from '../modules/input/input_raw'
include { flye } from '../modules/assembly/flye'

workflow {
	ch_versions = Channel.empty()

	if ( params.long_reads) {
		// Input
		ch_processed_reads = input_raw_lr()
		
		// ASSEMBLY
		ch_assembly = flye(ch_processed_reads)
		ch_versions = ch_versions.mix(ch_assembly.versions.first())
	} else {
		// Input
		ch_processed_reads = input_check()
		
		// ASSEMBLY
		ch_assembly = megahit(ch_processed_reads)
		ch_versions = ch_versions.mix(ch_assembly.versions.first())
	}
	// QUAST
	ch_quast = quast(ch_assembly.contigs)
	ch_quast_all = combine_quast(ch_quast.quast_res.collect())
	ch_versions = ch_versions.mix(ch_quast.versions.first())
	
	// BAKTA (internally runs prodigal)
	ch_bakta = bakta(ch_assembly.contigs, params.bakta_db_path)
	ch_versions = ch_versions.mix(ch_bakta.versions.first())

	// VERSION output
	ch_versions
		.unique()
		.collectFile(name: params.outdir + 'versions_assembly.yml')
	// Assembly location output
	ch_assembly.location.collectFile(name: params.outdir + '/stats/assemblies.csv', keepHeader: true)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nAssembly is done! Yay!\n" : "Oops .. something went wrong" )
}
