process checkm {
	publishDir params.outdir + "/binning/checkm", mode: params.publish_mode, pattern: 'checkm_*'
	tag "CheckM on $sample_id"

	input:
	tuple val(sample_id), path(dastool_bins)
	path(path_checkm_db)

	output:
	tuple val(sample_id), path("checkm_${sample_id}.tsv"), emit: checkm_out
	path "versions.yml", emit: versions

	shell:
	"""
	export CHECKM_DATA_PATH=${path_checkm_db}
	checkm lineage_wf -t $task.cpus -x fa \
		--tab_table -f checkm_${sample_id}.tsv \
		${dastool_bins} checkm_${sample_id}
	
	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    checkm: \$( checkm -h | head -n 2 | tail -n 1 | sed -e "s/.* CheckM v//g" | sed -e "s/ .*//g" )
	END_VERSIONS
	"""
}

