/* VIRAL ANNOTATION
 * Runs VIBRANT and geNomad on contigs, runs CheckV on the viruses.
*/

include { input_assembly } from './modules/input/input_assembly'

include { vibrant } from '../modules/viral_annotation/vibrant'
include { genomad } from '../modules/viral_annotation/genomad'
include { checkv } from '../modules/viral_annotation/checkv'


workflow {
  ch_input = input_assembly()
  ch_input.view()

  // VIBRANT
  ch_vibrant = vibrant(ch_input, params.vibrant_db_path)
  ch_versions = ch_versions.mix(ch_vibrant.versions.first())

  // geNomad
  ch_genomad = genomad(ch_input, params.genomad_db_path)
  ch_versions = ch_versions.mix(ch_genomad.versions.first())

  // checkV
  ch_checkv_vir = checkv(ch_vibrant.vibrant_phages, params.checkv_db_path, 'vibrant')
  ch_versions = ch_versions.mix(ch_checkv.versions.first())

  ch_checkv_gn = checkv(ch_genomad.genomad_phages, params.checkv_db_path, 'genomad')
  ch_versions = ch_versions.mix(ch_checkv.versions.first())

  // VERSION output
  ch_versions
    .unique()
    .collectFile(name: params.outdir + '/phage_annotation_versions.yml')
}

workflow.onComplete {
	log.info ( workflow.success ? "\nViral annotation is done! Yay!\n" : "Oops .. something went wrong" )
}
