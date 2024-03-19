
process prodigal { 
	publishDir params.outdir + "/assembly/prodigal/", pattern: "prodigal_*", mode: params.publish_mode
	tag "PRODIGAL on $sample_id"

	input:
	tuple val(sample_id), path(contigs)

	output:
	path("prodigal_${sample_id}")
	path "versions.yml", emit: versions

	shell:
	"""
	mkdir -p prodigal_${sample_id}
	prodigal -f gff -o ${sample_id}_prodigal_out.gff \
		-d ${sample_id}_genes.fna -a ${sample_id}_proteins.faa -p meta < $contigs
	mv ${sample_id}_* ./prodigal_${sample_id}	

	prodigal -v 2> prodigal.out || true
	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    prodigal: \$( cat prodigal.out | grep "Prodigal" | sed -e "s/Prodigal V//g" | sed -e "s/:.*//g" )
	END_VERSIONS
	"""
}

