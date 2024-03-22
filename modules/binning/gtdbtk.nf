process gtdbtk {
        publishDir params.outdir + "/binning/gtdb", mode: params.publish_mode, pattern: 'gtdb_*'
        tag "GTDB-tk on $sample_id"

        input:
        tuple val(sample_id), path(dastool_bins)
        path(path_gtdb_tk)

        output:
        tuple val(sample_id), path("gtdb_${sample_id}"), emit: gtdb_out
        path "versions.yml", emit: versions

        shell:
        """
        export GTDBTK_DATA_PATH=${path_gtdb_tk}
        gtdbtk classify_wf --cpus ${task.cpus} --pplacer_cpus ${task.cpus} \
                --skip_ani_screen \
                --genome_dir ${dastool_bins} -x fa --out_dir gtdb_${sample_id}
        
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            GTDB-tk: \$( gtdbtk -v | sed -e "s/gtdbtk: version //g" | sed -e "s/ Copyright.*//g" )
        END_VERSIONS
        """

}