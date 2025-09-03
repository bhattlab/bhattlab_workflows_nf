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

params.min_lr_len = 500
params.min_lr_qual = 10

process fastp {
	tag "fastp on $sample_id"

	input:
	tuple val(sample_id), path(reads)

	output:
	tuple val(sample_id), path("${sample_id}.qc.fq.gz"), emit: qc_reads
	path "versions.yml", emit: versions

	shell:
	"""
	fastplong -i ${reads} -o ${sample_id}.qc.fq.gz \
		--length_required ${params.min_lr_len} \
		--qualified_quality_phred ${params.min_lr_qual} \
		--json ${sample_id}.qc.json \
		--html ${sample_id}.qc.html --disable_adapter_trimming

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    fastplong: \$( fastplong --version | sed -e "s/fastplong //g" )
	END_VERSIONS
	"""

}
