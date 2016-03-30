% worker job scanner

identity_str='2199485[1]'; ids_parted=reshape(1:44,4,[]); ids_parted=ids_parted(1,:);

simu_time = 1e6;
p = 1000;
n_indirect = 10;
s_sparseness = linspace(1, round(sqrt(p*n_indirect)), 44)/p;
ncpu = 11;

s_sparseness = s_sparseness(ids_parted);

% function to be calculate in each loop
func_name = 'worker_cell_GC_HH_VST';

% for rng_state_curr
load('scan_sparseness/scan_HH3_gcc49_westmere2_nogui_sparse=1.0e-03-9.3e-02_p=1000_pr=1.0_ps=3.0e-02_scee=5.0e-02_t=1.0e+06_2199485[1].mat.rng', '-mat');

in_const_data.no_postprocess = true;

worker_head_sparse_test;

