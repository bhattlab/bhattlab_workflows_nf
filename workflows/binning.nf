#!/usr/bin/env nextflow

nextflow.enable.dsl=2


include { input_check } from './modules/input/input_check'
include { input_check_assembly } from './modules/input/input_assembly'

/* BINNING
 * Runs metabat2, maxbin, and Concoct on the contigs, then DAS tool
 * Check quality by CheckM or sth (maybe others)?
*/

include { binning_prep } from './modules/binning/binning_prep'
include { metabat } from './modules/binning/metabat'
include { maxbin } from './modules/binning/maxbin'
include { concoct } from './modules/binning/concoct'
include { dastool } from './modules/binning/dastool'
include { checkm } from './modules/binning/checkm'

workflow {

    ch_input_reads = input_check()
    ch_input_assembly = input_check_assembly()
    ch_input = ch_input_reads
        .concat(ch_input_assembly)
        .groupTuple()
        .map{ sampleid, info -> tuple(sampleid, info[0], info[1]) }
    ch_versions = Channel.empty()

    // PREPARE BINNING
    ch_binning_prep = binning_prep(ch_input)
    ch_versions = ch_versions.mix(ch_binning_prep.versions.first())
    
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

    // VERSION output
    ch_versions
        .unique()
        .collectFile(name: params.outdir + 'versions_binning.yml')
}

workflow.onComplete {
    log.info ( workflow.success ? "\nBinning is done! Yay!\n" : "Oops .. something went wrong" )
}
