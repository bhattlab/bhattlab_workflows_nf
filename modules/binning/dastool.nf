process dastool {
	publishDir params.outdir + "/binning/dastool", mode: params.publish_mode, pattern: "dastool_*"
	tag "DASTool on $sample_id"

	input:
	tuple val(sample_id), path(bins), path(depth), path(bam)

	output:
	tuple val(sample_id), path("dastool_${sample_id}"), emit: bins
	path "versions.yml", emit: versions

	script:
	"""
	Fasta_to_Contig2Bin.sh -e fa -i ${bins[1]} > metabat.tsv
	Fasta_to_Contig2Bin.sh -e fasta -i ${bins[2]} > maxbin.tsv
	Fasta_to_Contig2Bin.sh -e fa -i ${bins[3]} > concoct.tsv
	

	DAS_Tool -l metabat,maxbin,concoct --search_engine diamond \
		--threads $task.cpus --write_bins --write_unbinned \
		-i metabat.tsv,maxbin.tsv,concoct.tsv \
		-c ${bins[0]} -o dastool_${sample_id} || true

        if \$(grep -q "No bins with bin-score >0.5 found" dastool_${sample_id}_DASTool.log ) || \$(grep -q "single copy gene prediction using diamond failed" dastool_${sample_id}_DASTool.log )
        then
            mkdir dastool_${sample_id}
            cp ${bins[0]} ./dastool_${sample_id}/unbinned.fa
        elif ls dastool_${sample_id}_DASTool_bins/*.fa 1> /dev/null 2>&1
        then
            mv dastool_${sample_id}_DASTool_bins dastool_${sample_id}
            mv dastool_${sample_id}_DASTool_contig2bin.tsv ./dastool_${sample_id}
            mv dastool_${sample_id}_DASTool.log ./dastool_${sample_id}
            mv dastool_${sample_id}_DASTool_summary.tsv ./dastool_${sample_id}
        else
            echo "DAStool failed in an unexpected way!"
            exit 1
        fi
	
	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    DAS_Tool: \$( DAS_Tool -v | sed -e "s/DAS Tool //g" )
	END_VERSIONS
	"""

}
