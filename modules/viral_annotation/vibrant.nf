process vibrant {
  tag "Vibrant on $sample_id"
  publishDir params.outdir + "/viruses/vibrant/", mode: params.publish_mode, pattern: "vibrant_*"

  input:
  tuple val(sample_id), path(assembly)
  path(vibrant_db)

  output:
  tuple val(sample_id), path("vibrant_${sample_id}"), emit: vibrant_res
  tuple val(sample_id), path("all_phages_combined.fna"), emit: vibrant_phages
  path "versions.yml", emit: versions

  shell:
  """
  VIBRANT_run.py -i ${assembly} -t ${task.cpus} -f nucl \
    -folder ./vibrant_${sample_id} -no_plot -d ${vibrant_db}/databases \
    -m ${vibrant_db}/files
  cp ./vibrant_${sample_id}/VIBRANT*/VIBRANT_phages*/*phages_combined.fna ./all_phages_combined.fna

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      VIBRANT: \$( VIBRANT_run.py --version | sed -e "s/VIBRANT v//g" )
  END_VERSIONS
  """
}