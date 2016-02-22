%

simu_time = 1e6;
p = 200;
n_indirect = 10;
%s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 30)/p;
s_sparseness = sort(ceil(round(sqrt(p*n_indirect))*rand(1, 33)))/p;
ncpu = 11;

% function to be calculate in each loop
func_name = 'worker_cell_GC_HH_VST_v2';

worker_head_sparse_test;

