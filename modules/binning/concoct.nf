process concoct {
	tag "CONCOCT on $sample_id"
	
	input:
	tuple val(sample_id), path(contigs), path(depth), path(bam)

	output:
	tuple val(sample_id), path("concoct_${sample_id}.tsv"), emit: bins
	path "versions.yml", emit: versions
	
	script:
	"""
	# maybe this can fix the OpenBLAS error?
	# OMPI_MCA_pml="ucx" 
	# OMPI_MCA_osc="ucx"
	

	# concoct runs in multiple steps
	cut_up_fasta.py ${contigs} -c 10000 -o 0 --merge_last \
		-b ${sample_id}_contigs_10K.bed > ${sample_id}_contigs_10K.fa
	
	samtools index -@ $task.cpus ${bam}
	
	concoct_coverage_table.py ${sample_id}_contigs_10K.bed \
		${bam} > ${sample_id}_coverage_table.tsv
	
	concoct --composition_file ${sample_id}_contigs_10K.fa \
		--coverage_file ${sample_id}_coverage_table.tsv \
		-b concoct_${sample_id}/ --threads $task.cpus
	
	merge_cutup_clustering.py concoct_${sample_id}/clustering_gt1000.csv > \
		concoct_${sample_id}/clustering_merged.csv

	extract_fasta_bins.py ${contigs} concoct_${sample_id}/clustering_merged.csv \
		--output_path concoct_${sample_id}

	Fasta_to_Contig2Bin.sh -e fa -i concoct_${sample_id} > concoct_${sample_id}.tsv

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    concoct: \$( concoct -v | sed -e "s/concoct //g" )
	END_VERSIONS
	"""
}
