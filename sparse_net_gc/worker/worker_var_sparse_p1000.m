%

simu_time = 1e6;
p = 1000;
n_indirect = 10;
%s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 11)/p;
s_sparseness = sort(ceil(round(sqrt(p*n_indirect))*rand(1, 11)))/p;
ncpu = 11;
worker_head_sparse_test;

