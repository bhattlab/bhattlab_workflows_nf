
process bakta {
	publishDir "${params.outdir}/assembly/bakta/", mode: params.publish_mode, pattern: "bakta_${sample_id}/assembly.*"
  tag "Bakta on $sample_id"

	input:
  tuple val(sample_id), path(assembly)
  path database

  output:
  path "bakta_${sample_id}/assembly.tsv", emit: bakta_results_tsv
  path "bakta_${sample_id}/assembly.gff3", emit: bakta_results_gff
  path "bakta_${sample_id}/assembly.faa", emit: bakta_results_faa
  path "bakta_${sample_id}/assembly.hypotheticals.tsv", emit: bakta_results_hyp_tsv
  path "bakta_${sample_id}/assembly.hypotheticals.faa", emit: bakta_results_hyp_faa
  path "versions.yml", emit: versions

  shell:
  """
  mv ${assembly} assembly.fasta
  mkdir ./tmp
  bakta -t ${task.cpus} -o bakta_${sample_id} \
		--db ${database}  --skip-trna \
    --skip-tmrna --skip-ncrna --skip-ncrna-region --skip-crispr \
    --skip-sorf --skip-gap --compliant \
    --keep-contig-headers --meta assembly.fasta

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
  	bakta: \$( bakta --version | sed -e "s/bakta //g" )
  END_VERSIONS
  """
}

