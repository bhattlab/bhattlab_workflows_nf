process metabat {
	tag "METABAT on $sample_id"

	input:
	tuple val(sample_id), path(contigs), path(depth), path(bam)

	output:
	tuple val(sample_id), path("metabat_${sample_id}.tsv"), emit: bins
	path "versions.yml", emit: versions

	shell:
	'''
	# actual metabat binning
	metabat2 --seed 1 -t !{task.cpus} \
		--unbinned \
		--inFile !{contigs} \
		--outFile 'metabat_!{sample_id}/metabat_bins' \
		--abdFile !{depth}
        
	# if no bins produced, copy contigs to bin.unbinned
        if [ \$(ls metabat_!{sample_id} | wc -l ) == "0" ]; then
            cp !{contigs} metabat_!{sample_id}/metabat_bins.unbinned.fa
        fi

        # check for bin.tooShort.fa thats empty
        if [ -f metabat_!{sample_id}/metabat_bins.tooShort.fa ]; then
            echo "Found bin.tooShort.fa"
            if [ \$(cat metabat_!{sample_id}/metabat_bins.tooShort.fa | wc -l ) == "0" ]; then
                echo "Removing bin.tooShort.fa"
                rm metabat_!{sample_id}/metabat_bins.tooShort.fa
            fi
        fi

    Fasta_to_Contig2Bin.sh -e fa -i metabat_!{sample_id} > metabat_!{sample_id}_tmp.tsv
    cat metabat_!{sample_id}_tmp.tsv | grep -v "[unbinned|tooShort]$" | cut -f1,4 > metabat_!{sample_id}.tsv

    jgi_summarize_bam_contig_depths -h 2> jgi.version || true
	cat <<-END_VERSIONS > versions.yml
	"!{task.process}":
	    metabat2: \$( head -n 1 jgi.version | sed -e "s/jgi_summarize_bam_contig_depths //g" | sed -e "s/ (Bioconda).*//g" )
	END_VERSIONS
	'''
}
