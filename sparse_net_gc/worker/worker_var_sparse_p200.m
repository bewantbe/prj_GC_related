%

simu_time = 1e6;
p = 200;
n_indirect = 10;
s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 30)/p;
ncpu = 11;
prefix_tmpdata = ['data/' mfilename '_' datestr(now, 30) '_'];
worker_head_sparse_test;

