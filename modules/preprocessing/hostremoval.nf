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
    if [[ -f ${reads[1]} ]]
    then
        bwa mem -t $task.cpus ${host_genome_location}/${bwa_index_base} ${reads[0]} ${reads[1]} | \
            samtools fastq -t -T BX -f 4 -1 ${sample_id}_cleaned_1.fastq.gz -2 ${sample_id}_cleaned_2.fastq.gz -s ${sample_id}_cleanedtemp_singletons.fastq.gz -
        # run on unpaired reads
        bwa mem -t $task.cpus ${host_genome_location}/${bwa_index_base} ${reads[2]} | \
            samtools fastq -t -T BX -f 4  - > ${sample_id}_cleanedtemp_singletons2.fastq.gz
        # combine singletons
        zcat -f ${sample_id}_cleanedtemp_singletons.fastq.gz ${sample_id}_cleanedtemp_singletons2.fastq.gz | pigz > ${sample_id}_cleaned_orphans.fastq.gz
        rm ${sample_id}_cleanedtemp_singletons.fastq.gz ${sample_id}_cleanedtemp_singletons2.fastq.gz

        # output the location
        echo "${sample_id},${params.outdir}/preprocessed_reads/${sample_id}_cleaned_1.fastq.gz,${params.outdir}/preprocessed_reads/${sample_id}_cleaned_2.fastq.gz,${params.outdir}/preprocessed_reads/${sample_id}_cleaned_orphans.fastq.gz" > ${sample_id}.location
        readcount_paired=\$(echo \$((\$(zcat ${sample_id}_cleaned_1.fastq.gz | wc -l) / 2)))
        readcount_unpaired=\$(echo \$((\$(zcat ${sample_id}_cleaned_orphans.fastq.gz | wc -l) / 4)))
        totalcount=\$(echo \$((\$readcount_paired + \$readcount_unpaired)))

        echo ${sample_id}"\trmhost\t"\$totalcount >> "${stats}"
        echo ${sample_id}"\torphans\t"\${readcount_unpaired} >> "${stats}"
    else
        bwa mem -t $task.cpus -o single_mapped.sam ${host_genome_location}/${bwa_index_base} ${reads} 
        samtools fastq --threads ${task.cpus} -t -T BX -f 4 single_mapped.sam > ${sample_id}_cleaned.fastq
        rm single_mapped.sam
        pigz -p ${task.cpus} ${sample_id}_cleaned_orphans.fastq

        # output the location
        echo "${sample_id},${params.outdir}/preprocessed_reads/${sample_id}_cleaned.fastq.gz" > ${sample_id}.location
        
        readcount_unpaired=\$(echo \$((\$(zcat ${sample_id}_cleaned.fastq.gz | wc -l) / 4)))
        
        echo ${sample_id}"\trmhost\t"\${readcount_unpaired} >> "${stats}"
        echo ${sample_id}"\torphans\t"\${readcount_unpaired} >> "${stats}"
    fi

    bwa 2> bwa.version || true
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bwa: \$( cat bwa.version | grep Version | sed -e "s/Version: //g" )
    END_VERSIONS
    """

}

process hostremoval_lr {
    publishDir params.outdir + "/cleaned_reads/", mode: params.publish_mode, pattern: "reads_*"
    tag "Host removal for $sample_id"

    input:
    tuple val(sample_id), path(reads)
    path host_genome_location
    val bwa_index_base

    output:
    tuple val(sample_id), path("reads_${sample_id}.fastq.gz"), emit: reads
    path("${sample_id}.location"), emit: read_loc
    path "versions.yml", emit: versions

    shell:
    """
    minimap2 -x map-ont -t ${task.cpus} -y -a ${host_genome_location}/${bwa_index_base} ${reads} > out.sam
    samtools fastq --threads ${task.cpus} -T '*' -n -f4 out.sam > reads_${sample_id}.fastq
    gzip reads_${sample_id}.fastq  
    echo "${sample_id},${params.outdir}/cleaned_reads/reads_${sample_id}.fastq.gz" > ${sample_id}.location
  
    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        minimap2: \$( minimap2 --version )
        samtools: \$( samtools --version | head -n 1 | sed -e "s/samtools //g" )
    END_VERSIONS
    """
}
