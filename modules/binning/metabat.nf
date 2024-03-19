process metabat {
	publishDir params.outdir + "/binning/metabat", mode: params.publish_mode, pattern: "metabat_*"
	tag "METABAT on $sample_id"

	input:
	tuple val(sample_id), path(contigs), path(depth), path(bam)

	output:
	tuple val(sample_id), path("metabat_${sample_id}"), emit: bins
	path "versions.yml", emit: versions

	script:
	"""
	# actual metabat binning
	metabat2 --seed 1 -t $task.cpus \
		--unbinned \
		--inFile ${contigs} \
		--outFile 'metabat_${sample_id}/metabat_bins' \
		--abdFile ${depth}
        
	# if no bins produced, copy contigs to bin.unbinned
        if [ \$(ls metabat_${sample_id} | wc -l ) == "0" ]; then
            cp ${contigs} metabat_{sample_id}/metabat_bins.unbinned.fa
        fi

        # check for bin.tooShort.fa thats empty
        if [ -f metabat_{sample_id}/metabat_bins.tooShort.fa ]; then
            echo "Found bin.tooShort.fa"
            if [ \$(cat metabat_{sample_id}/metabat_bins.tooShort.fa | wc -l ) == "0" ]; then
                echo "Removing bin.tooShort.fa"
                rm metabat_{sample_id}/metabat_bins.tooShort.fa
            fi
        fi

    jgi_summarize_bam_contig_depths -h 2> jgi.version || true
	cat <<-END_VERSIONS > versions.yml
	"${task.process}":
	    metabat2: \$( head -n 1 jgi.version | sed -e "s/jgi_summarize_bam_contig_depths //g" | sed -e "s/ (Bioconda).*//g" )
	END_VERSIONS
	"""
}
