process nanoplot {
	publishDir params.outdir + "/stats/nanoplot/", mode: params.publish_mode, pattern: "nanoplot_*"
	tag "Nanoplot on $sample_id"

	input:
	tuple val(sample_id), path(reads)
	val type

	output:
	path "nanoplot_${sample_id}_${type}", emit: nanoplot
	path "versions.yml", emit: versions

	shell:
	"""
	NanoPlot -t ${task.cpus} \
	    -o nanoplot_${sample_id}_${type} --tsv_stats --fastq ${reads} --plots dot
	
	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    Nanoplot: \$( NanoPlot -v | sed -e "s/Nanoplot //g" )
	END_VERSIONS
  """
}