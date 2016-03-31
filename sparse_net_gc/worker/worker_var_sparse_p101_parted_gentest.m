%

identity_str='test101';
ids_parted = 1:8;
in_const_data.no_postprocess = true;


simu_time = 1e4;
p = 101;
n_indirect = 10;
s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 8)/p;
ncpu = 4;

s_sparseness = s_sparseness(ids_parted);

% function to be calculate in each loop
func_name = 'worker_cell_GC_HH_VST';

worker_head_sparse_test;

