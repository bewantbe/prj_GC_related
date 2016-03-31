%

identity_str='test101';
ids_parted = 1:22;
in_const_data.no_postprocess = true;


simu_time = 1e5;
p = 101;
n_indirect = 10;
s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 22)/p;
ncpu = 11;

s_sparseness = s_sparseness(ids_parted);

% function to be calculate in each loop
func_name = 'worker_cell_GC_HH_VST';

worker_head_sparse_test;

