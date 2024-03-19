#!/opt/conda/bin/python

import sys
import csv

out_file = sys.argv[1]
file_out = open(out_file, 'w')
file_out.write('Sample\traw_reads\tdedup_reads\tdedup_frac\ttrimmed_reads\ttrimmed_frac\thostremoved_reads\thostremoved_frac\torphan_reads\torphan_frac\n')

count_files = sys.argv[2:]

for sample_file in count_files:

	read_dict = {}

	with open(sample_file) as f:
		for line in f:
			(sampleid, read_type, number) = line.rstrip().split('\t')
			read_dict[read_type] = int(number)

	raw_reads = read_dict['raw']
	dedup_reads = read_dict['dedup']
	trimmed_reads = read_dict['trimmed']
	rmhost_reads = read_dict['rmhost']
	orphan_reads = read_dict['orphans']

	dedup_frac = round(dedup_reads / float(raw_reads), 3)
	trimmed_frac = round(trimmed_reads / float(raw_reads), 3)
	rmhost_frac = round(rmhost_reads / float(raw_reads), 3)
	orphan_frac = round(orphan_reads / float(raw_reads), 3)

	line = '\t'.join([sampleid, str(raw_reads),
		str(dedup_reads), str(dedup_frac),
        	str(trimmed_reads), str(trimmed_frac),
        	str(rmhost_reads), str(rmhost_frac),
        	str(orphan_reads), str(orphan_frac)]) + '\n'
	file_out.write(line)

file_out.close()

