% Generate HH data
% work with GCHH_analyse_core.m

net_param.generator  = 'gen_sparse_mt19937';
net_param.p          = 200;
net_param.sparseness = 100/net_param.p;
net_param.seed       = 124;
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

i_stv   = 1;  % Down sampling factor

clear('pm');
pm.neuron_model = 'HH3_gcc49_native';  % HH3_gcc49_sparse
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = floor(net_param.p * 0.25);
pm.scee = 0.02;
pm.scie = 0.02;
pm.scei = 0.10;
pm.scii = 0.10;
pm.pr   = 0.7;
pm.ps   = 0.032;  % 0.032 = 1 mV
pm.t    = 1e6;
pm.stv  = 0.5;

max_od = 40;

%gen_HH(pm, 'ext_T,cmd');
%[X, ISI, ras, pm] = gen_HH(pm, 'ext_T, new, rm');

b_use_spike_train = false;
GCHH_analyse_core                 % cost h, t = s cal GC.
b_use_spike_train = true;
GCHH_analyse_core                 % cost h, t = s cal GC.

