#!/bin/bash
#SBATCH -p serial
# Set number of nodes to run
#SBATCH --nodes=1
# Set number of tasks to run
#SBATCH --ntasks=1
# Set number of cores per task (default is 1)
#SBATCH --cpus-per-task=28
#SBATCH --mem=32G
# Walltime format hh:mm:ss
#SBATCH --time=2:00:00
# Output and error files
#SBATCH -o job.%J.out
#SBATCH -e job.%J.err
##SBATCH --mail-user=yx742@nyu.edu
##SBATCH --mail-type=ALL

# sbatch serial-job_gain.sh
# squeue -u $USER
# sacct --format="JobID,CPUTime,MaxRSS" -j <your-job-id>
# scancel <your-job-id>

module purge
module load NYUAD/3.0
module load boost
module load eigen
module load gcc
module load matlab

export MATLABPATH=$HOME/matcode/prj_GC_clean/HH_reboot/

matlab -nodesktop -nosplash -nodisplay -r "scan_ISI_prps_ps_mV_LIFGH_w1; exit;"

