#!/usr/bin/env nextflow

nextflow.enable.dsl=2

/* BINNING on short reads
 * Runs metabat2, maxbin, and Concoct on the contigs, then DAS tool
 * Check quality by CheckM or sth (maybe others)?
*/

include { input_check } from '../modules/input/input_check'
include { input_check_assembly } from '../modules/input/input_assembly'
include { binning_prep } from '../modules/binning/binning_prep'
include { metabat } from '../modules/binning/metabat'
include { maxbin } from '../modules/binning/maxbin'
include { concoct } from '../modules/binning/concoct'
include { dastool } from '../modules/binning/dastool'
include { checkm } from '../modules/binning/checkm'
include { gtdbtk } from '../modules/binning/gtdbtk'

/* BINNING on long reads
 * basically the same, but the preparation is different, since we
 * have to map via minimap2 instead of bwa
*/

include { input_raw_lr } from '../modules/input/input_raw'
include { binning_prep_lr } from '../modules/binning/binning_prep'
include { binning_prep_lr_bam } from '../modules/binning/binning_prep'

workflow {
    ch_versions = Channel.empty()
    ch_input_assembly = input_check_assembly()
    
    if ( params.long_reads) {
        ch_input_reads = input_raw_lr()

        ch_input = ch_input_reads
            .concat(ch_input_assembly)
            .groupTuple()
            .map{ sampleid, info -> tuple(sampleid, info[0], info[1])}
        ch_input.view()
        
        // PREPARE BINNING for long reads
        ch_bams = binning_prep_lr_bam(ch_input)
        ch_versions = ch_versions.mix(ch_bams.versions.first())
        ch_bams.bin_bam.view()

        // Re-mix channels
        ch_input_bin = ch_input
            .concat(ch_bams.bin_bam)
            .groupTuple(size=2)
        ch_input_bin.view()


        ch_binning_prep = binning_prep_lr(ch_input_bin)
        ch_versions = ch_versions.mix(ch_binning_prep.versions.first())
    } 
    else {
        ch_input_reads = input_check()

        ch_input = ch_input_reads
            .concat(ch_input_assembly)
            .groupTuple()
            .map{ sampleid, info -> tuple(sampleid, info[0], info[1]) }
    
        // PREPARE BINNING
        ch_binning_prep = binning_prep(ch_input)
        ch_versions = ch_versions.mix(ch_binning_prep.versions.first())
    }
    
    // METABAT
    ch_metabat = metabat(ch_binning_prep.bin_prep)
    ch_versions = ch_versions.mix(ch_metabat.versions.first())

    // MAXBIN
    ch_maxbin = maxbin(ch_binning_prep.bin_prep)
    ch_versions = ch_versions.mix(ch_maxbin.versions.first())

    // CONCOCT
    ch_concoct = concoct(ch_binning_prep.bin_prep)
    ch_versions = ch_versions.mix(ch_concoct.versions.first())

    // combine bins for each method for dastool
    ch_final =  ch_binning_prep.bin_prep
        .concat(ch_metabat.bins)
        .concat(ch_maxbin.bins)
        .concat(ch_concoct.bins)
        .groupTuple(size: 4)

    // run DAStool
    ch_dastool = dastool(ch_final)
    ch_versions = ch_versions.mix(ch_dastool.versions.first())

    // run checkM on DAStool bins
    ch_checkm = checkm(ch_dastool.bins, params.checkm_db_path)
    ch_versions = ch_versions.mix(ch_checkm.versions.first())

    // GTDB-tk
    ch_gtdb = gtdbtk(ch_dastool.bins, params.gtdb_db_path)
    ch_versions = ch_versions.mix(ch_gtdb.versions.first())

    // VERSION output
    ch_versions
        .unique()
        .collectFile(name: params.outdir + 'versions_binning.yml')
}

workflow.onComplete {
    log.info ( workflow.success ? "\nBinning is done! Yay!\n" : "Oops .. something went wrong" )
}
