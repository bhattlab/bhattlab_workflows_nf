process cenote_taker3 {
  tag "cenote-taker3 on $sample_id"
  publishDir params.outdir + "/viruses/ct3/", mode: params.publish_mode, pattern: "ct3_*"

  input:
  tuple val(sample_id), path(assembly)
  path(ct3_db)

  output:
  tuple val(sample_id), path("ct3_${sample_id}"), emit: ct3_res
  tuple val(sample_id), path("all_phages.fna"), emit: ct3_phages
  path "versions.yml", emit: versions

  shell:
  """
  cenotetaker3 -c ${assembly} -r ct3_${sample_id} -p T --lin_minimum_hallmark_genes 2 -t ${task.cpus} --cenote-dbs ${ct3_db} 
  cp ./ct3_${sample_id}/*_virus_sequences.fna ./all_phages.fna

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      cenote-taker3: \$( cenotetaker3 --version | tail -n 1 )
  END_VERSIONS
  """
}