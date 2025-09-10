process megahit {
	publishDir params.outdir + "/assembly/megahit/", mode: params.publish_mode, pattern: "${sample_id}.contigs.fa"
	tag "MEGAHIT on $sample_id"

	input:
	tuple val(sample_id), path(reads)

	output:
	tuple val(sample_id), path("${sample_id}.contigs.fa"), emit: contigs
	path "versions.yml", emit: versions
	path "location.csv", emit: location

	shell:
	"""
	if ${params.single_end}
	then
		megahit -r ${reads} -o megahit_${sample_id} \
			--out-prefix ${sample_id} -t ${task.cpus} 
	else
		megahit -1 ${reads[0]} -2 ${reads[1]} -o megahit_${sample_id} \
			--out-prefix ${sample_id} -t ${task.cpus} 
	fi
	mv megahit_${sample_id}/${sample_id}.contigs.fa ${sample_id}.contigs.fa

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    megahit: \$( megahit --version | sed -e "s/MEGAHIT v//g" )
	END_VERSIONS
	
	cat <<-END_LOCATION > location.csv
	sampleID,contigs
	${sample_id},${params.outdir}/assembly/megahit/${sample_id}.contigs.fa
	END_LOCATION
	"""
}
