process genomad {
  tag "geNomad on $sample_id"
  publishDir params.outdir + "/viruses/genomad/", mode: params.publish_mode, pattern: "genomad_*"

  input:
  tuple val(sample_id), path(assembly)
  path(genomad_db)

  output:
  tuple val(sample_id), path("genomad_${sample_id}"), emit: genomad_res
  tuple val(sample_id), path("all_phages.fna"), emit: genomad_phages
  path "versions.yml", emit: versions

  shell:
  """
  /opt/conda/bin/genomad  end-to-end --disable-nn-classification \
    --threads ${task.cpus} ${assembly} ./genomad_${sample} ${genomad_db}
  cp ./genomad_${sample_id}/*summary/*_virus.fna ./all_phages.fna

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      geNomad: \$( genomad --version | sed -e "s/geNomad, version //g" )
  END_VERSIONS
  """
}