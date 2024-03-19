params.trimgalore_quality =  30
params.trimgalore_min_read_length = 60

process trimgalore {
    tag "TRIMGALORE on $sample_id"

    input:
    tuple val(sample_id), path(reads)
    tuple val(sample_id), path(stats)

    output:
    tuple val(sample_id), path("${sample_id}_{R1_val_1,R2_val_2,val_unpaired}.fq.gz"), emit: reads
    tuple val(sample_id), path("${stats}"), emit: stats
    path "versions.yml", emit: versions

    script:
    """
    trim_galore --quality ${params.trimgalore_quality} --length ${params.trimgalore_min_read_length} \
        --paired ${reads[0]} ${reads[1]} --retain_unpaired
    zcat -f ${sample_id}_dedup_R1_unpaired_1.fq.gz ${sample_id}_dedup_R2_unpaired_2.fq.gz | pigz -b 32 > ${sample_id}_val_unpaired.fq.gz
    rm ${sample_id}_dedup_R1_unpaired_1.fq.gz ${sample_id}_dedup_R2_unpaired_2.fq.gz
    mv ${sample_id}_dedup_R1_val_1.fq.gz ${sample_id}_R1_val_1.fq.gz
    mv ${sample_id}_dedup_R2_val_2.fq.gz ${sample_id}_R2_val_2.fq.gz
    readcount_paired=\$(echo \$((\$(zcat ${sample_id}_R1_val_1.fq.gz | wc -l) / 2)))
    readcount_unpaired=\$(echo \$((\$(zcat ${sample_id}_val_unpaired.fq.gz | wc -l) / 4)))
    
    totalcount=\$(echo \$((\$readcount_paired + \$readcount_unpaired)))
    echo ${sample_id}"\ttrimmed\t"\$totalcount >> "${stats}"

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trim_galore: \$( trim_galore -v | head -n 4 | tail -n 1 | sed -e "s/.*version //g" )
    END_VERSIONS

    """
}


