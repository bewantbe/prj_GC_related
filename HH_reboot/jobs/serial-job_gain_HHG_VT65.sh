#!/bin/bash
# Set number of nodes to run
#SBATCH --nodes=1
# Set number of tasks to run
#SBATCH --ntasks-per-node=1
# Set number of cores per task (default is 1)
#SBATCH --cpus-per-task=28
#SBATCH --mem=32G
# Walltime format hh:mm:ss
#SBATCH --time=5:00:00
# Output and error files
#SBATCH -o job.%J.out
#SBATCH -e job.%J.err
##SBATCH --mail-user=yx742@nyu.edu
##SBATCH --mail-type=ALL

# sbatch serial-job_gain.sh
# squeue -u $USER
# sacct --format="JobID,CPUTime,AllocCPUS,state,MaxRSS,AveDiskWrite,ConsumedEnergy" -j <your-job-id>
# scancel <your-job-id>

# run on Prince
module purge
module load boost/gnu/1.62.0
module load eigen/3.3.1
module load gcc/6.3.0
module load matlab/2017a

matlab -nodesktop -nosplash -nodisplay -r "addpath('~/matcode/prj_GC_clean/HH_reboot/'); scan_ISI_prps_ps_mV_HHG_VT65_w2; exit;"

