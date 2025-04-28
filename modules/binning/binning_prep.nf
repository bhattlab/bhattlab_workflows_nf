
process binning_prep {
	tag "BINNING_PREP on $sample_id"

	input:
	tuple val(sample_id), path(reads), path(contigs)

	output:
	tuple val(sample_id), path(contigs), path("${sample_id}.depth.txt"), path("align_${sample_id}.bam"), emit: bin_prep
	path "versions.yml", emit: versions

	script:
	
	"""
	# make an index for the contigs and align the reads to get the depth
	mkdir -p ./idx_${sample_id}
	mv $contigs ./idx_${sample_id}
	bwa index ./idx_${sample_id}/${contigs}
	
	if [[ -f ${reads[1]} ]]
	then
		echo "paired reads!"
		bwa mem -t $task.cpus ./idx_${sample_id}/${contigs} ${reads[0]} ${reads[1]} | samtools sort --threads $task.cpus > align_${sample_id}.bam
		if [[ -f ${reads[2]} ]]
		then
			# what about orphans? guess we ignore them for now?
			# seems that like jgi_summarize can take several bam files?
			# update: map them as well and merge the bamfiles
			echo "Also map the orphans!"
			bwa mem -t $task.cpus ./idx_${sample_id}/${contigs} ${reads[2]} | samtools sort --threads $task.cpus > align_orphans_${sample_id}.bam
			mv align_${sample_id}.bam align_PE_${sample_id}.bam
			samtools merge -o align_${sample_id}.bam --threads $task.cpus align_PE_${sample_id}.bam align_orphans_${sample_id}.bam
		fi
	else
		echo "single-end reads!"
		bwa mem -t $task.cpus ./idx_${sample_id}/${contigs} ${reads} | samtools sort --threads $task.cpus > align_${sample_id}.bam
	fi
	samtools sort -@ $task.cpus align_${sample_id}.bam

	jgi_summarize_bam_contig_depths --outputDepth ${sample_id}.depth.txt \
		--pairedContigs ${sample_id}.paired.txt --minContigLength 1000 \
		--minContigDepth 1 --percentIdentity 50 ./align_${sample_id}.bam

	mv ./idx_${sample_id}/${contigs} ./
	# add versions here
	bwa 2> bwa.version || true
	jgi_summarize_bam_contig_depths -h 2> jgi.version || true
	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    bwa: \$( cat bwa.version | grep Version | sed -e "s/Version: //g" )
	    samtools: \$( samtools --version | head -n 1 | sed -e "s/samtools //g" )
	    metabat2: \$( head -n 1 jgi.version | sed -e "s/jgi_summarize_bam_contig_depths //g" | sed -e "s/ (Bioconda).*//g" )
	END_VERSIONS
	"""
}


process binning_prep_lr_bam {
	tag "BINNING_PREP bam on $sample_id"

	input:
	tuple val(sample_id), path(info)

	output:
	tuple val(sample_id), path("${info[0]}"), path("${info[1]}"), path("${sample_id}.bam"), emit: bin_bam
	path "versions.yml", emit: versions

	script:
	"""
	minimap2 -x map-ont -t ${task.cpus} \
		-a ${info[1]} ${info[0]} | samtools sort --threads ${task.cpus} > ${sample_id}.bam

	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    minimap2: \$( minimap2 --version )
	    samtools: \$( samtools --version | head -n 1 | sed -e "s/samtools //g" )
	END_VERSIONS
	"""

}

process binning_prep_lr {
	tag "BINNING_PREP on $sample_id"

	input:
	tuple val(sample_id), path(reads), path(contigs), path(bam)

	output:
	tuple val(sample_id), path(contigs), path("${sample_id}.depth.txt"), path(bam), emit: bin_prep
	path "versions.yml", emit: versions

	script:
	
	"""

	jgi_summarize_bam_contig_depths --outputDepth ${sample_id}.depth.txt \
		--pairedContigs ${sample_id}.paired.txt --minContigLength 1000 \
		--minContigDepth 1 --percentIdentity 50 ${bam}

	jgi_summarize_bam_contig_depths -h 2> jgi.version || true
	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    samtools: \$( samtools --version | head -n 1 | sed -e "s/samtools //g" )
	    metabat2: \$( head -n 1 jgi.version | sed -e "s/jgi_summarize_bam_contig_depths //g" | sed -e "s/ (Bioconda).*//g" )
	END_VERSIONS
	"""
}

