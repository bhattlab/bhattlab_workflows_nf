#!/usr/bin/env nextflow

nextflow.enable.dsl=2


include { input_check } from '../modules/input/input_check'

/* CLASSIFICATION
 * Processes for motus, metaphlan, phanta (including kraken2)
*/

include { motus } from  '../modules/classification/motus'
include { collate_motus } from '../modules/classification/motus'
include { metaphlan } from '../modules/classification/metaphlan'
include { collate_metaphlan } from '../modules/classification/metaphlan'

workflow {

	// Input
	ch_processed_reads = input_check()
	ch_versions = Channel.empty()

	// CLASSIFICATION
	if (params.run_motus) {
		ch_motus = motus(ch_processed_reads.reads, params.motus_db_path)
		ch_all_motus = collate_motus(ch_motus.motus_res.collect(), 
			params.motus_db_path,
			params.motus_gtdb_path)
		ch_versions = ch_versions.mix(ch_motus.versions.first())
		ch_versions = ch_versions.mix(ch_all_motus.versions.first())
	}
	if (params.run_metaphlan) {
		ch_metaphlan = metaphlan(ch_processed_reads.reads, params.metaphlan_db_path)
		ch_all_metaphlan = collate_metaphlan(ch_metaphlan.metaphlan_res.collect(), 
			ch_metaphlan.metaphlan_res_gtdb.collect())
		ch_versions = ch_versions.mix(ch_metaphlan.versions.first())
		ch_versions = ch_versions.mix(ch_all_metaphlan.versions.first())
	}

	// VERSION output
	ch_versions
		.unique()
		.collectFile(name: params.outdir + 'versions_classification.yml', sort: true)
}

workflow.onComplete {
	log.info ( workflow.success ? "\nClassification is done! Yay!\n" : "Oops .. something went wrong" )
}
