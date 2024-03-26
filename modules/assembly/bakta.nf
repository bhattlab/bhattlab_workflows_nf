
process bakta {
	publishDir params.outdir + "/bakta/", mode: params.publish_mode, pattern: "bakta_*"
  tag "Bakta on $sample_id"

	input:
  tuple val(sample_id), path(assembly)
  path database

  output:
  path "bakta_${sample_id}", emit: bakta_results
  path "versions.yml", emit: versions

  shell:
  """
  bakta -t ${task.cpus} -o bakta_${sample_id} \
		--db ${database}  --skip-trna \
    --skip-tmrna --skip-ncrna --skip-ncrna-region --skip-crispr \
    --skip-sorf --skip-gap \
    --keep-contig-headers --meta ${assembly}

  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
  	bakta: \$( bakta --version | sed -e "s/bakta //g" )
  END_VERSIONS
  """
}

