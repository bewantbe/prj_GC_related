%

simu_time = 1e5;
p = 100;
n_indirect = 10;
%s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 30)/p;
s_sparseness = sort(ceil(round(sqrt(p*n_indirect))*rand(1, 4)))/p;
prefix_tmpdata = ['data/' mfilename '_' datestr(now, 30) '_'];

worker_head_sparse_test;

