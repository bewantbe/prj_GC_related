%

simu_time = 2e4;
p = 100;
n_indirect = 10;
s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 8)/p;

%s_sparseness = s_sparseness(ids_parted);

% function to be calculate in each loop
func_name = 'worker_cell_GC_HH_VST_v2';

worker_head_sparse_test;

