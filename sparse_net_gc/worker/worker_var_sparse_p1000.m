%

simu_time = 1e6;
p = 1000;
n_indirect = 10;
s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 12)/p;
ncpu = 12;
worker_head_sparse_test;

