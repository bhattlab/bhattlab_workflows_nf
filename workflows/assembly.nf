#!/usr/bin/env nextflow

nextflow.enable.dsl=2


include { input_check } from './modules/input/input_check'

/* ASSEMBLY
 run megahit, prodigal, and quast
*/

include { megahit } from './modules/assembly/megahit'
include { quast } from './modules/assembly/quast'
include { combine_quast } from './modules/assembly/quast'
include { prodigal } from './modules/assembly/prodigal'


workflow {

	// Input
	ch_processed_reads = input_check()
	ch_versions = Channel.empty()

	// ASSEMBLY
	ch_megahit = megahit(ch_processed_reads)
	ch_versions = ch_versions.mix(ch_megahit.versions.first())

	// QUAST
	ch_quast = quast(ch_megahit.contigs)
	ch_quast_all = combine_quast(ch_quast.quast_res.collect())
	ch_versions = ch_versions.mix(ch_quast.versions.first())
	
	// PRODIGAL
	ch_prodigal = prodigal(ch_megahit.contigs)
	ch_versions = ch_versions.mix(ch_prodigal.versions.first())

	// VERSION output
	ch_versions
		.unique()
		.collectFile(name: params.outdir + 'versions_assembly.yml')
	// Assembly location output
	ch_megahit.location.collectFile(name: params.outdir + '/stats/assemblies.csv', keepHeader: true)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nAssembly is done! Yay!\n" : "Oops .. something went wrong" )
}
