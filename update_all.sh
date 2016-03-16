#!/bin/bash

#ssh farxhp7
#ssh far502
#ssh farzdz
#ssh fardell
#ssh nyuad

hg pull
hg push

hg pull far502
hg push far502

hg pull farzdz
hg push farzdz

hg pull fardell
hg push fardell

hg pull nyuad
hg push nyuad

hg pull farnyuad
hg push farnyuad
# also in cd /scratch/yx742/matcode/prj_GC_clean/; hg pull ~/matcode/prj_GC_clean/

# rsynca /home/xyy/matcode/job/job-2016-02-15/matlab_j02_400.pbs farnyuad:/scratch/yx742/matcode/prj_GC_clean/sparse_net_gc/worker/

# qsub -I -q interactive -l nodes=1:ppn=12
