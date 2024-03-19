#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { input_check } from './modules/input/input_check'

/* SOURMASH
 * Trim low abundant k-mers, run sourmash, and compare
*/

include { sourmash } from  './modules/sourmash/sourmash'
include { sourmash_compare } from './modules/sourmash/sourmash'

workflow {

	// Input
	ch_processed_reads = input_check()
	// SOURMASH
	ch_sourmash = sourmash(ch_processed_reads.reads)
	ch_compare = sourmash_compare(ch_sourmash.collect())
}

workflow.onComplete {
	log.info ( workflow.success ? "\nSourmash is done! Yay!\n" : "Oops .. something went wrong" )
}
