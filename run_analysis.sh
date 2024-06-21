#!/bin/bash -l

# Example batch script to run a Python script in a virtual environment.

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

# Set the working directory to project directory in your scratch space.
#$ -wd $HOME/Scratch/myriad-python-analysis-example

# Load python3 module - this must be the same version as loaded when creating and
# installing dependencies in the virtual environment
module load python3/3.11

# Define a local variable pointing to the project directory in your scratch space
PROJECT_DIR=/home/<your_UCL_id>/Scratch/myriad-python-analysis-example

# Activate the virtual environment in which you installed the project dependencies
source $PROJECT_DIR/venv/bin/activate

# Change current working directory to temporary file system on node
cd $TMPDIR

# Make a directory save analysis script outputs to
mkdir outputs

# Run analysis script using Python in activated virtual environment passing in path to
# directory containing input data and path to directory to write outputs to
echo "Running analysis script..."
python $PROJECT_DIR/run_analysis.py --data-dir $PROJECT_DIR/data --output-dir outputs
echo "...done."

# Copy script outputs back to scratch space under a job ID specific subdirectory
echo "Copying analysis outputs to scratch space..."
rsync -a outputs/ $PROJECT_DIR/outputs_$JOB_ID/
echo "...done"
