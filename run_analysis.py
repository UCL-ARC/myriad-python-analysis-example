"""Script for computing and plotting summary statistics of a batch of CSV data files."""

import argparse
import glob
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt


# Parse data-dir and output-dir arguments
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--data-dir", type=Path, help="Path to directory containing data")
parser.add_argument("--output-dir", type=Path, help="Path to directory to write analysis outputs to")
args = parser.parse_args()

# Iterate over all data files matching pattern *.csv in data directory
for data_file_path in sorted(args.data_dir.glob("*.csv")):
    # Load data as an array from CSV file, plot summary stats and save figure to output directory
    data = np.loadtxt(fname=data_file_path, delimiter=",")
    fig, axes = plt.subplots(1, 3, figsize=(10, 3))
    for ax, statistic_function in zip(axes, (np.mean, np.max, np.min)):
        ax.plot(statistic_function(data, axis=0))
        ax.set(ylabel=f"{statistic_function.__name__.capitalize()}")
    fig.tight_layout()
    fig.savefig(args.output_dir / f"{data_file_path.stem}-plot.pdf") 
