process checkv {
  publishDir params.outdir + "/viruses/checkv/", mode: params.publish_mode, pattern: "checkv_${sample_id}_${type}/*"
  tag "CheckV on $sample_id"

  input:
  tuple val(sample_id), path(phages)
  path(path_checkv_db)
  val(type)

  output:
  path("checkv_${sample_id}_${type}/quality_summary.tsv"), emit: checkv_out
  path("checkv_${sample_id}_${type}/contamination.tsv"), emit: checkv_contamination
  path "versions.yml", emit: versions

  shell:
  """
  checkv end_to_end ${phages} \
     checkv_${sample_id}_${type} --remove_tmp -t ${task.cpus} -d ${path_checkv_db}
  
  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      checkv: \$( checkv -h | head -n 1 | sed 's/CheckV v//g' | sed 's/: .*//g' )
  END_VERSIONS
  """
}
