process myloasm {
	publishDir params.outdir + "/assembly/myloasm/", mode: params.publish_mode, pattern: "myloasm_*/*"
	tag "myloasm on $sample_id"

	input:
	tuple val(sample_id), path(reads)

	output:
	tuple val("${sample_id}_myloasm"), path("myloasm_${sample_id}/assembly.fasta"), emit: contigs
	tuple val(sample_id), path("myloasm_${sample_id}/assembly_graph.gfa"), emit: graph
	tuple val(sample_id), path("myloasm_${sample_id}/myloasm.log"), emit: log
	path "versions.yml", emit: versions
	path "location_${sample_id}.csv", emit: location

	shell:
	"""
	myloasm ${reads} \
		-o myloasm_${sample_id} \
		-t ${task.cpus} \
		--clean-dir --min-reads-contig 3

	mv myloasm_${sample_id}/assembly_primary.fa myloasm_${sample_id}/assembly.fasta
	mv myloasm_${sample_id}/final_contig_graph.gfa myloasm_${sample_id}/assembly_graph.gfa
	mv myloasm_${sample_id}/myloasm_*.log myloasm_${sample_id}/myloasm.log

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    myloasm: \$( myloasm --version | sed -e "s/myloasm //g" )
	END_VERSIONS

	cat <<-END_LOCATION > location_${sample_id}.csv
	sampleID,contigs
	${sample_id},${params.outdir}/assembly/myloasm/myloasm_${sample_id}/assembly.fasta
	END_LOCATION

	"""
}
