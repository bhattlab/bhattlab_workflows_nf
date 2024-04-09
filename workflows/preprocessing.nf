#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/* PREPROCESSING of short reads
 * Processes for fastqc, multiqc, and read processing, including
 * deduplication, trimming, human read removal
*/

include { input_raw } from '../modules/input/input_raw'
include { combine_fastqs } from '../modules/input/combine_fastqs'
include { fastqc as fastqc_pre } from '../modules/preprocessing/fastqc'
include { fastqc as fastqc_post } from '../modules/preprocessing/fastqc'
include { multiqc as multiqc_pre } from '../modules/preprocessing/multiqc'
include { multiqc as multiqc_post } from '../modules/preprocessing/multiqc'
include { deduplicate } from '../modules/preprocessing/deduplicate'
include { trimgalore } from '../modules/preprocessing/trimgalore'
include { hostremoval } from '../modules/preprocessing/hostremoval'
include { aggregatereports } from '../modules/preprocessing/aggregate'

/* PREPROCESSING of long reads
 * Processes for nanoplot and host removal
*/

include { input_raw_lr } from '../modules/input/input_raw'
include { nanoplot as nanoplot_pre } from '../modules/preprocessing/nanoplot'
include { nanoplot as nanoplot_post } from '../modules/preprocessing/nanoplot'
include { hostremoval_lr } from '../modules/preprocessing/hostremoval'
include { aggregatereports_lr } from '../modules/preprocessing/aggregate'

workflow {

	ch_versions = Channel.empty()

	if ( params.long_reads) {
		ch_raw_reads = input_raw_lr()
		
		// Nanoplot before host removal
		ch_nanoplot = nanoplot_pre(ch_raw_reads, 'pre')
		ch_versions = ch_versions.mix(ch_nanoplot.versions.first())

		// host removal
		ch_host_removed = hostremoval_lr(ch_raw_eads, 
				params.host_genome_location, 
				params.bwa_index_base)
  	ch_versions = ch_versions.mix(ch_host_removed.versions.first())

  	// NanoPlot after host removal
  	ch_nanoplot_post = nanoplot_post(ch_host_removed.reads, 'post')
		
		// Aggregate results
		ch_stats = ch_nanoplot.nanoplot.collect()
    	.concat(ch_nanoplot_post.nanoplot.collect()).collect()
  	ch_seq_stats = aggregatereports_lr(ch_stats, 
  		ch_host_removed.read_loc.collect(),
  		params.outdir + "/stats/preprocessed_reads.csv",
  		params.outdir + "/stats/sequencing_stats.tsv")
	}
	else {
		ch_read_pairs = input_raw()

		// Combine fastqs that were sequenced across multiple lanes
		ch_reads_combined = combine_fastqs( ch_read_pairs
			.groupTuple()
			.map{ sample, reads -> [sample, reads.flatten()] } )
		
		// PREPROCESSING
		// FASTQC
		ch_fastqc = fastqc_pre(ch_reads_combined, "pre")
		ch_versions = ch_versions.mix(ch_fastqc.versions.first())

		// MULTIQC
		ch_multiqc_pre = multiqc_pre(ch_fastqc.fastqc.collect(), "pre", params.outdir + "/stats/fastqc")
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
		multiqc_post(ch_postfastqc.fastqc.collect(), "post", params.outdir + "/stats/fastqc")

		// AGGREGATE REPORTS
		aggregatereports(ch_host_remove.stats.collect(), 
						ch_host_remove.read_loc.collect(),
						params.outdir + "/stats/preprocessed_reads.csv",
						params.outdir + "/stats/read_counts.tsv")
	}

	// VERSION output
	ch_versions
		.unique()
		.collectFile(name: params.outdir + 'versions_preprocessing.yml')

}

workflow.onComplete {
	log.info ( workflow.success ? "\nPreprocessing is done! Yay!\n" : "Oops .. something went wrong with the preprocessing" )
}
