process flye {
	publishDir params.outdir + "/assembly/flye/", mode: params.publish_mode, pattern: "flye_*"
	tag "Meta-Flye on $sample_id"

	input:
	tuple val(sample_id), path(reads)

	output:
	tuple val(sample_id), path("flye_${sample_id}"), emit: assembly
	tuple val(sample_id), path("${sample_id}.contigs.fa"), emit: contigs
	path "versions.yml", emit: versions
	path "location_${sample_id}.csv", emit: location

	shell:
	"""
	flye --nano-hq ${reads} --out-dir flye_${sample_id} --meta \
		--threads ${task.cpus} --genome-size 200m
	cp ./flye_${sample_id}/assembly.fasta ./${sample_id}.contigs.fa

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    flye: \$( flye -v )
	END_VERSIONS

	cat <<-END_LOCATION > location_${sample_id}.csv
	sampleID,contigs
	${sample_id},${params.outdir}/assembly/flye/flye_${sample_id}/assembly.fasta
	END_LOCATION

	"""
}