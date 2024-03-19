#!/usr/bin/env nextflow

nextflow.enable.dsl=2

include { input_raw } from '../modules/input/input_raw'
include { combine_fastqs } from '../modules/input/combine_fastqs'

/* PREPROCESSING
 * Processes for fastqc, multiqc, and read processing, including
 * deduplication, trimming, human read removal
*/

include { fastqc as fastqc_pre } from '../modules/preprocessing/fastqc'
include { fastqc as fastqc_post } from '../modules/preprocessing/fastqc'
include { multiqc as multiqc_pre } from '../modules/preprocessing/multiqc'
include { multiqc as multiqc_post } from '../modules/preprocessing/multiqc'
include { deduplicate } from '../modules/preprocessing/deduplicate'
include { trimgalore } from '../modules/preprocessing/trimgalore'
include { hostremoval } from '../modules/preprocessing/hostremoval'
include { aggregatereports } from '../modules/preprocessing/aggregate'

workflow {
	ch_read_pairs = input_raw()
	ch_versions = Channel.empty()

	// Combine fastqs that were sequenced across multiple lanes
	ch_reads_combined = combine_fastqs( ch_read_pairs
		.groupTuple()
		.map{ sample, reads -> [sample, reads.flatten()] } )
	
	// PREPROCESSING
	// FASTQC
	ch_fastqc = fastqc_pre(ch_reads_combined, "pre")
	ch_versions = ch_versions.mix(ch_fastqc.versions.first())

	// MULTIQC
	ch_multiqc_pre = multiqc_pre(ch_fastqc.fastqc.collect(), "pre")
	ch_versions = ch_versions.mix(ch_multiqc_pre.versions.first())

	// DEDUPLICATION
	ch_deduplicated = deduplicate(ch_reads_combined)
	ch_versions = ch_versions.mix(ch_deduplicated.versions.first())

	// TRIMMING
	ch_trim_galore = trimgalore(ch_deduplicated.reads, ch_deduplicated.stats)
	ch_versions = ch_versions.mix(ch_trim_galore.versions.first())

	// HOST REMOVAL
	ch_host_remove = hostremoval(ch_trim_galore.reads, 
					ch_trim_galore.stats, 
					params.host_genome_location, 
					params.bwa_index_base)
	ch_versions = ch_versions.mix(ch_host_remove.versions.first())

	// FASTQC again
	ch_postfastqc = fastqc_post(ch_host_remove.reads, "post")

	// MULTIQC again
	multiqc_post(ch_postfastqc.fastqc.collect(), "post")

	// AGGREGATE REPORTS
	aggregatereports(ch_host_remove.stats.collect(), 
					ch_host_remove.read_loc.collect(),
					params.outdir + "/stats/preprocessed_reads.csv",
					params.outdir + "/stats/read_counts.tsv")

	// VERSION output
	ch_versions
		.unique()
		.collectFile(name: params.outdir + 'versions_preprocessing.yml')

}

workflow.onComplete {
	log.info ( workflow.success ? "\nPreprocessing is done! Yay!\n" : "Oops .. something went wrong with the preprocessing" )
}
