process dastool {
	publishDir params.outdir + "/binning/dastool", mode: params.publish_mode, pattern: "dastool_*"
	tag "DASTool on $sample_id"

	input:
	tuple val(sample_id), path(bins), path(depth), path(bam)

	output:
	tuple val(sample_id), path("checkm_input_${sample_id}.tsv"), emit: bins_checkm
	tuple val(sample_id), path("gtdbtk_input_${sample_id}.tsv"), emit: bins_gtdbtk
        tuple val(sample_id), path("dastool_${sample_id}_bins.tar.gz"), emit: dastool_bins
	path "versions.yml", emit: versions

	shell:
	'''
	DAS_Tool -l metabat,maxbin,concoct --search_engine diamond \
		--threads !{task.cpus} --write_bins --write_unbinned \
		-i !{bins[1]},!{bins[2]},!{bins[3]} \
		-c !{bins[0]} -o dastool_!{sample_id} || true

        if \$(grep -q "No bins with bin-score >0.5 found" dastool_!{sample_id}_DASTool.log ) || \$(grep -q "single copy gene prediction using diamond failed" dastool_!{sample_id}_DASTool.log )
        then
            mkdir dastool_!{sample_id}
            cp !{bins[0]} ./dastool_!{sample_id}/unbinned.fa
            echo "No bins founds!"
	    exit 1
        elif ls dastool_!{sample_id}_DASTool_bins/*.fa 1> /dev/null 2>&1
        then
            mv dastool_!{sample_id}_DASTool_bins dastool_!{sample_id}
            mv dastool_!{sample_id}_DASTool_contig2bin.tsv ./dastool_!{sample_id}
            mv dastool_!{sample_id}_DASTool.log ./dastool_!{sample_id}
            mv dastool_!{sample_id}_DASTool_summary.tsv ./dastool_!{sample_id}
            cp !{bins[1]} ./dastool_!{sample_id}
            cp !{bins[2]} ./dastool_!{sample_id}
            cp !{bins[3]} ./dastool_!{sample_id}
        else
            echo "DAStool failed in an unexpected way!"
            exit 1
        fi

        # create tsv files for checkm and GTDB-tk
        cd dastool_!{sample_id}
        find "$(pwd)" -maxdepth 1 -type f -name "*.fa" -exec realpath {} \\; | awk -F/ '{print $NF "\t" $0}' | grep -v unbinned > ../checkm_input_!{sample_id}.tsv
        find "$(pwd)" -maxdepth 1 -type f -name "*.fa" -exec realpath {} \\; | awk -F/ '{print $0 "\t" $NF}' | grep -v unbinned > ../gtdbtk_input_!{sample_id}.tsv
	
        cd ../
	
        # tar the bins and keep that as output
        tar -czvf dastool_!{sample_id}_bins.tar.gz dastool_!{sample_id}

	cat <<-END_VERSIONS > versions.yml
	"!{task.process}":
	    DAS_Tool: \$( DAS_Tool -v | sed -e "s/DAS Tool //g" )
	END_VERSIONS
	'''
}
