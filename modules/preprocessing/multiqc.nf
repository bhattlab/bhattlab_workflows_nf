process multiqc {
    publishDir params.outdir + "/stats/multiqc/", mode: params.publish_mode, pattern: "multiqc*"
    tag "MULTIQC before anything"

    input:
    path '*'
    val(type)
    path(old_results)

    output:
    path 'multiqc_*', emit: multiqc
    path "versions.yml", emit: versions

    script:
    """

    mkdir all_new_fastq
    mv *.zip ./all_new_fastq
    mv *.html ./all_new_fastq

    cp -n ${old_results}/${type}*/* ./all_new_fastq
    
    multiqc --filename multiqc_${type}_report.html ./all_new_fastq

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}
