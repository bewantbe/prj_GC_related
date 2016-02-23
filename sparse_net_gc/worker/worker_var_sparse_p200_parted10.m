%

simu_time = 1e6;
p = 200;
n_indirect = 10;
s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 44)/p;
ncpu = 11;

s_sparseness = s_sparseness(ids_parted);

% function to be calculate in each loop
func_name = 'worker_cell_GC_HH_VST_v2';

worker_head_sparse_test;

