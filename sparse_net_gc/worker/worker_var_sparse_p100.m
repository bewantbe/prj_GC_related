%

simu_time = 1e4;
p = 100;
n_indirect = 10;
%s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 30)/p;
s_sparseness = sort(ceil(round(sqrt(p*n_indirect))*rand(1, 4)))/p;

worker_head_sparse_test;

