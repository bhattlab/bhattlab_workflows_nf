process maxbin {
	
	tag "MAXBIN on $sample_id"

	input:
	tuple val(sample_id), path(contigs), path(depth), path(bam)

	output:
	tuple val(sample_id), path("maxbin_${sample_id}.tsv"), emit: bins
	path "versions.yml", emit: versions

	script:
	"""
	# adjust the depth file
	mkdir -p maxbin_${sample_id}
	cut -f 1,4 ${depth} | tail -n +2 > ${depth}.adjusted
	run_MaxBin.pl -contig ${contigs} -out maxbin_${sample_id}/maxbin_bins \
		-abund ${depth}.adjusted -thread $task.cpus || true

	Fasta_to_Contig2Bin.sh -e fasta -i maxbin_${sample_id} > maxbin_${sample_id}.tsv

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    maxbin: \$( run_MaxBin.pl | head -n 1 | sed -e "s/MaxBin //g" )
	END_VERSIONS
	"""
}
