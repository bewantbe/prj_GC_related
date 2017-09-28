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
#SBATCH --time=5:00:00
# Output and error files
#SBATCH -o job.%J.out
#SBATCH -e job.%J.err
##SBATCH --mail-user=yx742@nyu.edu
##SBATCH --mail-type=ALL

module purge
module load NYUAD/3.0
module load boost
module load eigen
module load gcc
module load matlab

matlab -nodesktop -nosplash -nodisplay -r "addpath('~/matcode/prj_GC_clean/HH_reboot/'); scan_ISI_prps_ps_mV_HHGH_VT20_w2; exit;"

