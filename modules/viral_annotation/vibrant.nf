process vibrant {
  publishDir params.outdir + "/phageannotation/vibrant/", mode: params.publish_mode
  tag "VIBRANT for $sample_id"

  input:
  tuple val(sample_id), path(assembly)

  output:
  path "${sample_id}/VIBRANT_${sample_id}.contigs/VIBRANT_phages_${sample_id}.contigs/${sample_id}.contigs.phages_combined.fna", emit: vibrant_all
  path "${sample_id}/VIBRANT_${sample_id}.contigs/VIBRANT_phages_${sample_id}.contigs/${sample_id}.contigs.phages_lysogenic.fna", emit: vibrant_lysogenic
  path "${sample_id}/VIBRANT_${sample_id}.contigs/VIBRANT_phages_${sample_id}.contigs/${sample_id}.contigs.phages_lytic.fna", emit: vibrant_lytic
  path "${sample_id}/VIBRANT_${sample_id}.contigs/VIBRANT_phages_${sample_id}.contigs/${sample_id}.contigs.phages_circular.fna", emit: vibrant_circular
  path "${sample_id}/VIBRANT_${sample_id}.contigs/VIBRANT_results_${sample_id}.contigs/VIBRANT_genome_quality_${sample_id}.contigs.tsv", emit: vibrant_quality
  path "${sample_id}/VIBRANT_${sample_id}.contigs/VIBRANT_results_${sample_id}.contigs/VIBRANT_integrated_prophage_coordinates_${sample_id}.contigs.tsv", emit: vibrant_coordinates



  script:
  """
  VIBRANT_run.py -i ${assembly} -t $task.cpus -f nucl -folder ${sample_id} -no_plot
  """

}
