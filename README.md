# Running a Python script on UCL's Myriad cluster

This repository gives an example of how to run a Python analysis script on UCL's [Myriad](https://www.rc.ucl.ac.uk/docs/Clusters/Myriad/) cluster.

> [!TIP]
> This example is intentionally minimal and has only relatively sparse notes and explanations of the steps required.
> A much fuller introduction to using UCL's research computing platforms is available in the
> [_Introduction to high performance computing at UCL_ course on Moodle](https://moodle.ucl.ac.uk/course/view.php?id=33216)
> which is available both for self-paced study and is also delivered as a synchronous workshop.
> There is also [extensive user documentation for UCL's researching computing platforms](https://www.rc.ucl.ac.uk/docs/).

The script is run in a [Python intepreter](https://docs.python.org/3/tutorial/interpreter.html) installed in a [virtual environment](https://docs.python.org/3/tutorial/venv.html)  which has been set up with the required versions of third-party packages.
The example here installs [NumPy](https://numpy.org/) and [Matplotlib](https://matplotlib.org/).
The Python package requirements are specified in the [`requirements.txt`](requirements.txt) file.
To set up an environment with a different set of requirements you can simply replace the example `requirements.txt` file here with one for your use case - for example to export a list of the Python packages installed in an existing environment run
```bash
python -m pip freeze > requirements.txt
```

The [script here](run_analysis.py) loads a sequence of comma separated value (CSV) files from a data directory, computes summary statistics along the row axis, plots these using Matplotlib and save the plots to an output directory.
It illustrates using Pythons built-in [argparse](https://docs.python.org/3/library/argparse.html) module to parse command-line arguments passed to the script specifying the paths to the directories containing the data files and which to write the analysis result out to.

## Getting this example repository on Myriad

To create a local copy of this repository in your scratch space on Myriad, first [log-in using `ssh`](https://www.rc.ucl.ac.uk/docs/howto/#how-do-i-log-in), and then from the resulting command prompt run

```bash
cd ~/Scratch
git clone https://github.com/UCL-ARC/myriad-python-analysis-example
cd myriad-python-analysis-example
```

In order these commands will:
- change the current working directory to your scratch space,
- clone this repository using Git into your scratch space,
- change the current working directory to the root directory of the cloned repository.

## Setting up a virtual environment on Myriad

Myriad has a range of software pre-installed, including modules for [various versions of Python](https://www.rc.ucl.ac.uk/docs/Installed_Software_Lists/module-packages/).
Here we will load a Python version from one of the pre-installed modules and then [create a virtual environment to install our project specific dependencies in](https://www.rc.ucl.ac.uk/docs/Software_Guides/Installing_Software/#using-your-own-virtualenv).

> [!TIP]
> In some cases you may be able to instead use the packages bundled with the [`python3` modules on Myriad](https://www.rc.ucl.ac.uk/docs/Installed_Software_Lists/python-packages/) to run your script if they already include all of the Python package dependencies you need.
> We illustrate the approach of setting up a virtual environment here as in some cases you may need specific packages or versions packages that are not available in the `python3` bundle modules.

Here we will create our virtual environment and install the necessary packages into it on a _login node_ on Myriad.

> [!CAUTION]
> The login nodes are the machines you gain access to when logging in to the cluster via `ssh`.
> They should only be used for tasks such as copying data files, setting up the environment to run a job and submitting jobs to the scheduler.
> Any computationally intensive tasks should be submitted as a job to the scheduler where it will run on a compute node, to ensure the login nodes, which are a shared resource across all users, remain responsive.

From the same command prompt (opened via `ssh`) you ran the commands in the previous section, first run

```bash
module load python3/3.11
```
to use the module system on Myriad to load the (at the time of writing) latest version of Python available on Myriad (in some cases you may wish to use an earlier version if you know your script or the packages it depends on requires a specific Python version).

To create a new virtual environment in a directory named `venv` in the current directory run
```bash
python -m venv venv
```
Once the environment has finished being set up you can run
```bash
source venv/bin/activate
```
to [activate](https://docs.python.org/3/library/venv.html#how-venvs-work) the environment.
Once the environment is activated, we can install the third-party Python packages required for running our analysis script by running
```bash
python -m pip install -r requirements.txt
```
from the root directory of your local clone of the repository (this should still be your working directory providing you have followed the steps as above).

## Getting data

There are a variety of approaches [for transferring data onto Myriad](https://www.rc.ucl.ac.uk/docs/howto/#how-do-i-transfer-data-onto-the-system).
Here we will illustrate getting a zipped data file from the Internet using a [command line utility `wget`](https://en.wikipedia.org/wiki/Wget) and unzipping the files.
We use as an example dataset the data from the [Software Carpentry](https://software-carpentry.org/) [_Programming with Python_ lesson](https://swcarpentry.github.io/python-novice-inflammation).

In the command prompt (running on a login node on Myriad that you accessed previously using `ssh`) run each of the following commands in turn
```bash
wget https://swcarpentry.github.io/python-novice-inflammation/data/python-novice-inflammation-data.zip
unzip python-novice-inflammation-data.zip
rm python-novice-inflammation-data.zip
```
In order they will,
- use `wget` to retrieve the dataset zipped archive file from the specified URL,
- use the `unzip` utility to extract the files from the downloaded archive,
- remove the archive file which is no longer needed.

If you now run

```bash
ls data
```
you should see a list of CSV files outputted.

> [!TIP]
> While downloading data from the internet is one option, in some cases you may have your data already stored elsewhere on UCL systems, for example in the [_Research Data Storage_ (RDS) service](https://www.ucl.ac.uk/advanced-research-computing/platforms-and-services/research-data-storage-service).
> There is a guide in the Research Computing documentation for [how to transfer data from the RDS to Myriad](https://www.rc.ucl.ac.uk/docs/Supplementary/Connecting_to_RDSS/#between-myriad-and-rdss).

## Submitting a job

To submit a job to the scheduler on Myriad for running on the compute nodes, you need to write a [job script](https://www.rc.ucl.ac.uk/docs/Example_Jobscripts/).
A job script both attaches metadata to the job describing for example [the resources required to run the job](https://www.rc.ucl.ac.uk/docs/Experienced_Users/#resources-you-can-request), and also specifies the commands the job should run.
We have included a minimal example job script for running the Python script [`run_analysis.py`](run_analysis.py) from the virtual environment you set up in a previous section.
The script here writes outputs to a local temporary directory on the compute node assigned to the job.
One the Python analysis script has completed, the outputs created by the script are copied from the local directory on the node back to your scratch space using [`rsync`](https://en.wikipedia.org/wiki/Rsync).

The job script needs to be edited to replace the placeholder `<your_UCL_id>` values with your UCL userid (the same one you used to login to Myriad with).
You can open the job script in [a basic terminal editor `nano`](https://en.wikipedia.org/wiki/GNU_nano),
```bash
nano run_analysis.sh
```
and change all occurences of `<your_UCL_id>` (including the angular brackets) to your specific userid, hitting `Ctrl+O` and then `Ctrl+X` to respectively save the changes and exit from `nano`.
Alternatively you can run the following [`sed` command](https://en.wikipedia.org/wiki/Sed) to globally replace `<your_UCL_id>` with the value of the variable `$USER` (which should correspond to your UCL userid)
```bash
sed -i "s/<your_UCL_id>/$USER/g" run_analysis.sh
```

Once you have updated the job script, it can be submitted to the scheduler system by running
```bash
qsub run_analysis.sh
```
This will output a message telling your job (which will be named `python-analysis-example` if you kept the defaults set in the job script) has been submitted and informing you of the assigned job ID.

## Checking job status and getting job outputs

You can [check on the status of your submitted job(s)](https://www.rc.ucl.ac.uk/docs/howto/#how-do-i-monitor-a-job) by running
```bash
qstat
```

When your job has completed running [several output files will be written](https://www.rc.ucl.ac.uk/docs/Job_Results/).
These files will have the naming scheme `<job_name>.<output_code><job_id>` where
- `<job_name>` is the name of the job in the submitted job script (for the example here `python-analysis-example`),
- `<output_code>` is one of several codes specifying the output type,
- `<job_id>` is the job ID assigned to the submitted job and output by the `qsub` command.

The main two output types and corresponding `<output_code>` values are
- `o` for captured output to `stdout` (for example the output from `print` calls in your Python script or `echo` commands in the job script),
- `e` for the captured output to `stderr` (any errors which occurred when running script including for example the tracebacks of Python exceptions).

The job script example here will copy the files outputted by the analysis script to a subdirectory named `output_<job_id>` where `<job_id>` is the job ID of the submitted job. For the example here this will consist of a set of PDF files corresponding to the saved summary statistic plots for each of the input data files.

You can list all the files output by the analysis script by running
```bash
ls outputs_<job_id>
```
where `<job_id>` is replaced with the relevant job ID assigned to the submitted job.

To transfer the job outputs back to your local system you can use [one of the options listed in the Research Computing documentation](https://www.rc.ucl.ac.uk/docs/howto/#how-do-i-transfer-data-onto-the-system).
