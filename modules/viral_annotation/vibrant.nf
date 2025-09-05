process vibrant {
  tag "Vibrant on $sample_id"
  publishDir params.outdir + "/viruses/vibrant/", mode: params.publish_mode, pattern: "vibrant_${sample_id}/*"

  input:
  tuple val(sample_id), path(assembly)
  path(vibrant_db)

  output:
  tuple val(sample_id), path("vibrant_${sample_id}/phage_info.tsv"), emit: vibrant_res
  tuple val(sample_id), path("vibrant_${sample_id}/all_phages.fna"), emit: vibrant_phages
  path "versions.yml", emit: versions

  shell:
  """
  cp ${assembly} assembly_fixed.fasta
  sed -i 's/ /_/g' assembly_fixed.fasta
  VIBRANT_run.py -i assembly_fixed.fasta -t ${task.cpus} -f nucl \
    -folder ./vibrant_${sample_id} -no_plot -d ${vibrant_db}/databases \
    -m ${vibrant_db}/files
  cp ./vibrant_${sample_id}/VIBRANT_assembly_fixed/VIBRANT_phages_assembly_fixed/assembly_fixed.phages_combined.fna ./vibrant_${sample_id}/all_phages.fna
  if [ -f ./vibrant_${sample_id}/VIBRANT_assembly_fixed/VIBRANT_results_assembly_fixed/VIBRANT_integrated_prophage_coordinates_assembly_fixed.tsv ]
  then
    cp ./vibrant_${sample_id}/VIBRANT_assembly_fixed/VIBRANT_results_assembly_fixed/VIBRANT_integrated_prophage_coordinates_assembly_fixed.tsv ./vibrant_${sample_id}/phage_info.tsv
  else 
    touch ./vibrant_${sample_id}/phage_info.tsv
  fi
  
  cat <<-END_VERSIONS > versions.yml
  "${task.process}":
      VIBRANT: \$( VIBRANT_run.py --version | sed -e "s/VIBRANT v//g" )
  END_VERSIONS
  """
}
