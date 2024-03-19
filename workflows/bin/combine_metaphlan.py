#!/opt/conda/bin/python

import sys
import os
import pandas as pd
from functools import reduce

out_dir = sys.argv[1]
out_file = sys.argv[2]

files_mpa = os.listdir(out_dir)
def read_mpa(x):
    sample = x.removesuffix('.out').removeprefix('metaphlan_')
    temp = pd.read_csv(out_dir + '/' + x, sep='\t', skiprows=4)
    temp = temp[['#clade_name', 'relative_abundance']]
    temp.rename(columns={'#clade_name': 'taxonomy', 'relative_abundance': sample}, inplace=True)
    return(temp)

dfs = [read_mpa(f) for f in files_mpa]
df_merged = reduce(lambda  left,right: pd.merge(left,right, on=['taxonomy'],
                                            how='outer'), dfs).fillna(0)
df_merged.to_csv(out_file, sep="\t", index=False)

