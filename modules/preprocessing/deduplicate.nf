process deduplicate {
    tag "DEDUPLICATION of reads on $sample_id"

    input:
    tuple val(sample_id), path(reads)
  
    output:
    tuple val(sample_id), path("${sample_id}_dedup_{R1,R2,SE}.fastq.gz"), emit: reads
    tuple val(sample_id), path("counts_${sample_id}.txt"), emit: stats
    path "versions.yml", emit: versions

    script:
    """
    if ${params.single_end}
    then
        hts_SuperDeduper -U ${reads} -f ${sample_id}_dedup -F
    else
        hts_SuperDeduper -1 ${reads[0]} -2 ${reads[1]} -f ${sample_id}_dedup -F
    fi
    
    count_deduplicate.py ${sample_id} stats.log > counts_${sample_id}.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        hts_SuperDeduper: \$( hts_SuperDeduper --version )
    END_VERSIONS
    """
}

