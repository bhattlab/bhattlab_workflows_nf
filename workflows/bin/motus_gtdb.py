#!/opt/conda/bin/python

import sys, csv, re

gtdb_file = sys.argv[1]
in_file = sys.argv[2]
out_file = sys.argv[3]

tax_map = {}
with open(gtdb_file, 'r') as csvfile:
	reader = csv.reader(csvfile, delimiter='\t')
	for row in reader:
		tax_map[row[0]] = ';'.join(row[1:len(row)])
tax_map["-1"] = "Unknown"
tax_map["unassigned"] = "Unknown"

new_data = {}
pattern=r"(ref_|meta_|ext_)mOTU_v[0-9]+_([0-9]+)"
with open(in_file, 'r') as infile:
	reader=csv.reader(infile, delimiter='\t')
	next(reader)
	next(reader)
	header_line = next(reader)
	for row in reader:
		if re.search(pattern, row[0]) is not None:
			motu_id = re.search(pattern, row[0]).group()
		else:
			motu_id = "-1"
		new_tax = tax_map[motu_id]
		if new_tax in new_data.keys():
			old_list = new_data[new_tax]
			new_list = [int(x) for  x in row[1:len(row)]]
			result = [a + b for a, b in zip(old_list, new_list)]
			new_data[new_tax] =  result
		else:
			new_data[new_tax] = [int(x) for x in row[1:len(row)]]

with open(out_file, 'w') as outfile:
	writer = csv.writer(outfile, delimiter='\t')
	writer.writerow(header_line)
	for tax in new_data.keys():
		writer.writerow([tax] + new_data[tax])

