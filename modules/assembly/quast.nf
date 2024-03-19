process quast {
  tag "QUAST on $sample_id"

  input:
  tuple val(sample_id), path(contigs)

  output:
  path("${sample_id}_report.tsv"), emit: quast_res
  path "versions.yml", emit: versions

  shell:
  """
  quast.py -o quast ${contigs} --fast
  mv ./quast/report.tsv ./${sample_id}_report.tsv

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      QUAST: \$( quast --version | grep "QUAST" | sed -e "s/QUAST v//g" )
  END_VERSIONS
  """
}

process combine_quast {
	publishDir params.outdir + "/assembly/", mode: params.publish_mode

	input:
	path(results)

	output:
	path("quast_report.tsv")
	
	shell:
	"""
	mkdir -p quast_all
	mv *report.tsv ./quast_all
	combine_quast.py ./quast_all
	"""
}

