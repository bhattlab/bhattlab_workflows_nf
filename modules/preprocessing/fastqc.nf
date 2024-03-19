process fastqc {
    publishDir params.outdir + "/stats/fastqc/", mode: params.publish_mode, pattern: "*logs/*"
    tag "${type}-FASTQC on $sample_id"

    input:
    tuple val(sample_id), path(reads)
    val(type)

    output:
    path "${type}fastqc_${sample_id}_logs/*", emit: fastqc
    path "versions.yml", emit: versions

    script:
    """
    mkdir ${type}fastqc_${sample_id}_logs
    fastqc -o ${type}fastqc_${sample_id}_logs -f fastq -q ${reads} -t ${task.cpus}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        fastqc: \$( fastqc --version | sed -e "s/FastQC v//g" )
    END_VERSIONS

    """
}
