process gtdbtk {
        publishDir params.outdir + "/binning/gtdb/", mode: params.publish_mode, pattern: 'gtdb_*'
        tag "GTDB-tk on $sample_id"

        input:
        tuple val(sample_id), path(dastool_bins)
        path(path_gtdb_tk)

        output:
        tuple val(sample_id), path("gtdb_${sample_id}.tsv"), emit: gtdb_out
        path "versions.yml", emit: versions

        shell:
        """
        export GTDBTK_DATA_PATH=${path_gtdb_tk}
        gtdbtk classify_wf --cpus ${task.cpus} --pplacer_cpus ${task.cpus} \
                --skip_ani_screen \
                --batchfile ${dastool_bins} -x fa --out_dir gtdb_${sample_id}       
	
	if [[ ! -f gtdb_${sample_id}/gtdbtk.bac120.summary.tsv ]]
        then
                if [[ ! -f gtdb_${sample_id}/gtdbtk.ar53.summary.tsv ]]
                then
                	echo "Something went seriously wrong!"
			exit
		fi
        fi
        cat ./gtdb_${sample_id}/gtdbtk.*.tsv | head -n 1 > gtdb_${sample_id}.tsv
        cat ./gtdb_${sample_id}/gtdbtk.*.tsv | grep -v -f gtdb_${sample_id}.tsv >> ./gtdb_${sample_id}.tsv
	
        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            GTDB-tk: \$( gtdbtk -v | sed -e "s/gtdbtk: version //g" | sed -e "s/ Copyright.*//g" )
        END_VERSIONS
        """
}

