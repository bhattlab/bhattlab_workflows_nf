process multiqc {
    publishDir params.outdir + "/stats/multiqc/", mode: params.publish_mode, pattern: "multiqc*"
    tag "MULTIQC before anything"

    input:
    path '*'
    val(type)

    output:
    path 'multiqc_*', emit: multiqc
    path "versions.yml", emit: versions

    script:
    """
    multiqc --filename multiqc_${type}_report.html .

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        multiqc: \$( multiqc --version | sed -e "s/multiqc, version //g" )
    END_VERSIONS
    """
}
