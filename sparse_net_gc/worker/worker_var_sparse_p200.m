%

simu_time = 1e6;
p = 200;
n_indirect = 10;
%s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 30)/p;
s_sparseness = sort(ceil(round(sqrt(p*n_indirect))*rand(1, 33)))/p;
ncpu = 11;
worker_head_sparse_test;

