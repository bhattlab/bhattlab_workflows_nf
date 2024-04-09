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

process aggregatereports_lr {
  publishDir params.outdir + "/stats/", mode: params.publish_mode

  input:
  path(results)
  path(read_location)
  path(read_summary)
  path(full_report)

  output:
  path ("sequencing_stats.csv")
  path("preprocessed_reads.csv")

  shell:
  '''
  set +u
  # prepare the full report on all the samples in this run
  echo "SampleID,number_of_reads,number_of_bases,median_read_length,mean_read_length,read_length_stdev,n50,mean_qual,median_qual" > sequencing_stats_tmp.csv

  for filename in nanoplot_*
  do
    prefix=$(echo "$filename" | sed 's/nanoplot_//')
    echo $prefix
    head -n 9 "$filename"/NanoStats.txt | awk -F'\\t' -v prefix="$prefix" 'NR == 1 { printf "%s", prefix; } NR > 1 { printf ",%s", $2; } END { printf "\\n"; }' >> sequencing_stats_tmp.csv
  done

  # combine with what is already there
  if [ -s !full_report ];
  then
    cat !full_report sequencing_stats_tmp.csv > combination.csv
  else
    cp sequencing_stats_tmp.csv combination.csv
  fi
  
  # take each uniq row
  awk '!a[$0]++' combination.csv 
  mv combination.csv sequencing_stats.csv

  echo "sampleID,reads" > preprocessed_reads_new.csv
  cat $read_location >> preprocessed_reads_new.csv
  if [ -s $read_summary ];
  then
    cat $read_summary preprocessed_reads_new.csv > combination.csv
  else
    cp preprocessed_reads_new.csv combination.csv
  fi
  awk '!a[\$0]++' combination.csv > combination_uniq.csv
  mv combination_uniq.csv preprocessed_reads.csv
  '''
}
