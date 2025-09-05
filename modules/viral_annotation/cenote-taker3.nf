process cenote_taker3 {
  tag "cenote-taker3 on $sample_id"
  publishDir params.outdir + "/viruses/ct3/", mode: params.publish_mode, pattern: "ct3_${sample_id}/*"

  input:
  tuple val(sample_id), path(assembly)
  path(ct3_db)

  output:
  tuple val(sample_id), path("ct3_${sample_id}/all_phages.fna"), emit: ct3_phages
  tuple val(sample_id), path("ct3_${sample_id}/phage_info.tsv"), emit: ct3_res
  tuple val(sample_id), path("ct3_${sample_id}/phage_info_full.tsv"), emit: ct3_res_full
  tuple val(sample_id), path("ct3_${sample_id}/contig_map.tsv"), emit: ct3_contig_map
  path "versions.yml", emit: versions

  shell:
  """
  mv ${assembly} assembly.fasta
  cenotetaker3 -c assembly.fasta -r assembly -p T \
    --lin_minimum_hallmark_genes 2 -t ${task.cpus} --cenote-dbs ${ct3_db} 
  
  mkdir ./ct3_${sample_id}
  cp ./assembly/assembly_virus_sequences.fna ./ct3_${sample_id}/all_phages.fna
  cp ./assembly/assembly_virus_summary.tsv ./ct3_${sample_id}/phage_info_full.tsv
  cp ./assembly/assembly_prune_summary.tsv ./ct3_${sample_id}/phage_info.tsv
  cp ./assembly/ct_processing/contig_name_map.tsv ./ct3_${sample_id}/contig_map.tsv

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      cenote-taker3: \$( cenotetaker3 --version | tail -n 1 )
  END_VERSIONS
  """
}
