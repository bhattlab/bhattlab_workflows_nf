process aggregatereports {
  publishDir params.outdir + "/stats", mode: params.publish_mode

  input:
  path(stats)
  path(read_location)
  path(read_summary)
  path(preproc_summary)

  output:
  path('read_counts.tsv')
  path('count_plot.pdf')
  path('preprocessed_reads.csv')

  script:
  """
  set +ue
  
  get_counts.py read_counts_new.tsv $stats
  # combine with what is already there
  if [ -s $preproc_summary ];
  then
    cat $preproc_summary read_counts_new.tsv > combination.tsv
  else
    cp read_counts_new.tsv combination.tsv
  fi
  awk '!a[\$0]++' combination.tsv > combination_uniq.tsv
  mv combination_uniq.tsv read_counts.tsv
  plot_counts.py read_counts.tsv

  # same for the read location stuff
  echo "sampleID,forward,reverse,orphans" > preprocessed_reads_new.csv
  cat $read_location >> preprocessed_reads_new.csv
  if [ -s $read_summary ];
  then
    cat $read_summary preprocessed_reads_new.csv > combination.csv
  else
    cp preprocessed_reads_new.csv combination.csv
  fi
  awk '!a[\$0]++' combination.csv > combination_uniq.csv
  mv combination_uniq.csv preprocessed_reads.csv
  """

}

