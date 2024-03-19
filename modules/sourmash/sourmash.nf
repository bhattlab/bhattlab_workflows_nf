
process sourmash {
	publishDir params.outdir + "/sourmash/signatures/", mode: params.publish_mode
	tag "sourmash for $sample_id"

	input:
	tuple val(sample_id), path(reads)

	output:
	path "${sample_id}.sig", emit: sourmash_res

	script:
	"""
	zcat -f ${reads[0]} ${reads[1]} ${reads[2]} > all_reads_${sample_id}.fq
	trim-low-abund.py -C 3 -Z 18 -V -M 32e9 all_reads_${sample_id}.fq
	rm all_reads_${sample_id}.fq
	sourmash compute --scaled 10000 all_reads_${sample_id}.fq.abundtrim \
		-o ${sample_id}.sig -k 21,31,51
	rm all_reads_${sample_id}.fq.abundtrim
	"""
}

process sourmash_compare { 
	publishDir params.outdir + "/sourmash", mode: params.publish_mode

	input:
	path(sourmash_res)

	output:
	path "sourmash_k*.csv"

	script:
	"""
	sourmash compare *.sig --csv sourmash_k21.csv -k 21 -p ${task.cpus}
	sourmash compare *.sig --csv sourmash_k31.csv -k 31 -p ${task.cpus}
	sourmash compare *.sig --csv sourmash_k51.csv -k 51 -p ${task.cpus}
	"""
}

