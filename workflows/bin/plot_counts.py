#!/opt/conda/bin/python

import sys
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages

read_color_pastel = {'raw': '#e34747',
                     'dedup': '#00aecd',
                     'trimmed': '#00d6a3',
                     'hostremoved': '#ff9f25',
                     'orphan': '#999999'}
read_color = {'raw': '#8C1515',
              'dedup': '#007C92',
              'trimmed': '#009B76',
              'hostremoved': '#E98300',
              'orphan': "#666666"}
sns.set_style("whitegrid",  {'xtick.bottom': True,'ytick.left': True, 'axes.edgecolor': 'black'})

# read in data
df = pd.read_csv(sys.argv[1], sep='\t')
df = df.melt(id_vars=['Sample'])
df[["Stage", "Type"]] = df.variable.str.split(pat='_', expand=True)

# plot raw reads and fraction of reads
with PdfPages('count_plot.pdf') as pdf_pages:
    x = plt.figure()
    read_counts = df[df['Type']=='reads']
    read_counts = read_counts[read_counts['Stage']!='orphan']
    ax = sns.boxplot(data=read_counts, x='Stage', y='value', 
                     palette=read_color_pastel, fliersize=0)
    sns.stripplot(data=read_counts, x='Stage', y='value', palette=read_color, hue='Stage')
    ax.set(xlabel='', ylabel='Number of reads (log10)', yscale='log')
    sns.despine()
    pdf_pages.savefig(x)
    
    y = plt.figure()
    read_fraction = df[df['Type']=='frac']
    ax2 = sns.boxplot(data=read_fraction, x='Stage', y='value', 
                     palette=read_color_pastel, fliersize=0)
    sns.stripplot(data=read_fraction, x='Stage', y='value', palette=read_color, hue='Stage')
    ax2.set(xlabel='', ylabel='Fraction or reads compared to raw reads')
    ax2.set(ylim=[0,1])
    sns.despine()
    pdf_pages.savefig(y)


