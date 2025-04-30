
process combine_fastqs {
	input:
	tuple val(sample_id), path(reads)

	output:
	tuple val(sample_id), path("${sample_id}_{1,2}.fastq.gz", includeInputs: true) 
	
	shell:
	'''
	echo !{sample_id}
	mkdir read_dir
	mv !{reads} ./read_dir
	forward_files="\$(find ./read_dir/ | grep -E ".*(_1)(\\.fastq\\.gz|\\.fq\\.gz)" | sort)"
	reverse_files="\$(find ./read_dir/ | grep -E ".*(_2)(\\.fastq\\.gz|\\.fq\\.gz)" | sort)"
	if [[ "\$(printf '%s\\n' "${forward_files[@]}" | wc -l)" -gt 1 ]]
	then
		unpigz -p 2 -c \${forward_files[@]} > "!{sample_id}_1.fastq"
		unpigz -p 2 -c \${reverse_files[@]} > "!{sample_id}_2.fastq"
		pigz -p 2 !{sample_id}_1.fastq
		pigz -p 2 !{sample_id}_2.fastq
	else
		ln -s ${forward_files} "!{sample_id}_1.fastq.gz"
		ln -s ${reverse_files} "!{sample_id}_2.fastq.gz"
	fi
	'''
}


process combine_fastqs_single {
	input:
	tuple val(sample_id), path(reads)

	output:
	tuple val(sample_id), path("${sample_id}_combined.fastq.gz") 
	
	shell:
	'''
	echo !{sample_id}
	if [[ -f !{reads[1]} ]]
	then
		unpigz -p 2 -c !{reads} > "!{sample_id}_combined.fastq"
		pigz -p 2 !{sample_id}_combined.fastq
	else
		ln -s !{reads} !{sample_id}_combined.fastq.gz
	fi
	'''
}
