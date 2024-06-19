#!/bin/bash -l

# Example batch script to run a Python script in a Conda environment.

# Request 1 minutes of wallclock time (format hours:minutes:seconds).
#$ -l h_rt=0:1:0

# Request 1 gigabyte of RAM for each core/thread 
# (must be an integer followed by M, G, or T)
#$ -l mem=1G

# Request 1 gigabyte of TMPDIR space (default is 10 GB)
#$ -l tmpfs=1G

# Set the name of the job.
#$ -N python-analysis-example

# Request 1 cores.
#$ -pe smp 1

# Set the working directory to somewhere in your scratch space.
# Replace "<your_UCL_id>" with your UCL user ID
#$ -wd /home/<your_UCL_id>/Scratch/myriad-python-analysis-example

# Load miniconda module and use to active Conda environment with dependencies installed
module load python/miniconda3/24.3.0-0
source $UCL_CONDA_PATH/etc/profile.d/conda.sh
conda activate python-analysis

# Change current working directory to temporary file system on node
cd $TMPDIR

# Make a directory save analysis script outputs to
mkdir outputs

#  Run analysis script using Python in activated Conda environment
# passing in path to directory containing input data and path to
# directory to write outputs to
echo "Running analysis script..."
python /home/<your_UCL_id>/Scratch/myriad-python-analysis-example/run_analysis.py \
  --data-dir /home/<your_UCL_id>/Scratch/myriad-python-analysis-example/data --output-dir outputs
echo "...done."

# Copy script outputs back to scratch space under a job ID specific subdirectory
echo "Copying analysis outputs to scratch space..."
rsync -a outputs/ /home/<your_UCL_id>/Scratch/myriad-python-analysis-example/outputs_$JOB_ID/
echo "...done"