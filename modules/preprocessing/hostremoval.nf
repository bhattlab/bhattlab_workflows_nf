process hostremoval {
    publishDir params.outdir  + "/preprocessed_reads", pattern: '*gz', mode: params.publish_mode
    tag "HOSTREMOVAL on $sample_id"

    input:
    tuple val(sample_id), path(reads)
    tuple val(sample_id), path(stats)
    path host_genome_location
    val bwa_index_base

    output:
    tuple val(sample_id), path("${sample_id}_cleaned_{1,2,orphans}.fastq.gz"), emit: reads
    path("${stats}"), emit: stats
    path("${sample_id}.location"), emit: read_loc
    path "versions.yml", emit: versions

    script:
    """
    bwa mem -t $task.cpus ${host_genome_location}/${bwa_index_base} ${reads[0]} ${reads[1]} | \
        samtools fastq -t -T BX -f 4 -1 ${sample_id}_cleaned_1.fastq.gz -2 ${sample_id}_cleaned_2.fastq.gz -s ${sample_id}_cleanedtemp_singletons.fastq.gz -
        # run on unpaired reads
    bwa mem -t $task.cpus ${host_genome_location}/${bwa_index_base} ${reads[2]} | \
        samtools fastq -t -T BX -f 4  - > ${sample_id}_cleanedtemp_singletons2.fastq.gz
    # combine singletons
    zcat -f ${sample_id}_cleanedtemp_singletons.fastq.gz ${sample_id}_cleanedtemp_singletons2.fastq.gz | pigz > ${sample_id}_cleaned_orphans.fastq.gz
    rm ${sample_id}_cleanedtemp_singletons.fastq.gz ${sample_id}_cleanedtemp_singletons2.fastq.gz
    readcount_paired=\$(echo \$((\$(zcat ${sample_id}_cleaned_1.fastq.gz | wc -l) / 2)))
    readcount_unpaired=\$(echo \$((\$(zcat ${sample_id}_cleaned_orphans.fastq.gz | wc -l) / 4)))
    totalcount=\$(echo \$((\$readcount_paired + \$readcount_unpaired)))
    echo ${sample_id}"\trmhost\t"\$totalcount >> "${stats}"
    echo ${sample_id}"\torphans\t"\${readcount_unpaired} >> "${stats}"
    echo "${sample_id},${params.outdir}/preprocessed_reads/${sample_id}_cleaned_1.fastq.gz,${params.outdir}/preprocessed_reads/${sample_id}_cleaned_2.fastq.gz,${params.outdir}/preprocessed_reads/${sample_id}_cleaned_orphans.fastq.gz" > ${sample_id}.location

    bwa 2> bwa.version || true
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$( cat bwa.version | grep Version | sed -e "s/Version: //g" )
    END_VERSIONS
    """

}

