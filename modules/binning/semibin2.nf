process semibin2 {
	tag "SEMIBIN2 on $sample_id"

	input:
	tuple val(sample_id), path(contigs), path(depth), path(bam)

	output:
	tuple val(sample_id), path("semibin2_${sample_id}.tsv"), emit: bins
	path "versions.yml", emit: versions

	script:
	def sequencing_type = params.long_reads ? "long_read" : "short_read"
	"""
	# actual semibin2 binning with the pre-trained model
	SemiBin2 single_easy_bin \
		--environment ${params.semibin2_environment} \
		--sequencing-type ${sequencing_type} \
		--threads $task.cpus \
		-i ${contigs} \
		-b ${bam} \
		-o semibin2_${sample_id} || true

	# if no bins produced (or the assembly is too small to bin), keep an
	# empty bin folder, so that DAStool can still run on the metabat bins
	mkdir -p semibin2_${sample_id}/output_bins

	# DAStool needs uncompressed fasta files
	find semibin2_${sample_id}/output_bins -name '*.gz' -exec gunzip -f {} +

	Fasta_to_Contig2Bin.sh -e fa -i semibin2_${sample_id}/output_bins > semibin2_${sample_id}.tsv || true

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    SemiBin2: \$( SemiBin2 --version 2>&1 | tail -n 1 )
	END_VERSIONS
	"""
}
