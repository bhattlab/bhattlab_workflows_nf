process genomad {
  tag "geNomad on $sample_id"
  publishDir params.outdir + "/viruses/genomad/", mode: params.publish_mode, pattern: "genomad_${sample_id}/*"

  input:
  tuple val(sample_id), path(assembly)
  path(genomad_db)

  output:
  tuple val(sample_id), path("genomad_${sample_id}/phage_info.tsv"), emit: genomad_phage_res
  tuple val(sample_id), path("genomad_${sample_id}/all_phages.fna"), emit: genomad_phages
  tuple val(sample_id), path("genomad_${sample_id}/plasmid_info.tsv"), emit: genomad_plasmid_res
  tuple val(sample_id), path("genomad_${sample_id}/all_plasmids.fna"), emit: genomad_plasmids
  path "versions.yml", emit: versions

  shell:
  """
  mv ${assembly} assembly.fasta
  genomad  end-to-end --disable-nn-classification \
    --threads ${task.cpus} assembly.fasta ./genomad_${sample_id} ${genomad_db}
  cp ./genomad_${sample_id}/assembly_summary/assembly_virus.fna ./genomad_${sample_id}/all_phages.fna
  cp ./genomad_${sample_id}/assembly_summary/assembly_virus_summary.tsv ./genomad_${sample_id}/phage_info.tsv
  cp ./genomad_${sample_id}/assembly_summary/assembly_plasmid.fna ./genomad_${sample_id}/all_plasmids.fna
  cp ./genomad_${sample_id}/assembly_summary/assembly_plasmid_summary.tsv ./genomad_${sample_id}/plasmid_info.tsv

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      geNomad: \$( genomad --version | sed -e "s/geNomad, version //g" )
  END_VERSIONS
  """
}
