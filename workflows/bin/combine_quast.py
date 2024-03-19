#!/opt/conda/bin/python

import sys
import os
import pandas as pd
from functools import reduce

out_dir = sys.argv[1]

files_quast = os.listdir(out_dir)
def read_quast(x):
    sample = x.removesuffix('_report.tsv')
    temp = pd.read_csv(out_dir + '/' + x, sep='\t')
    temp.rename(columns={'Assembly': 'stats', temp.columns[1]: sample}, inplace=True)
    return(temp)

dfs = [read_quast(f) for f in files_quast]
df_merged = reduce(lambda  left,right: pd.merge(left,right, on=['stats'],
                                            how='outer'), dfs).fillna(0)
df_merged.to_csv('quast_report.tsv', sep="\t", index=False)

