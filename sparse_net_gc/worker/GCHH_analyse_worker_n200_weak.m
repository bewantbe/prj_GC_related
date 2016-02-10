% Generate HH data
% work with GCHH_analyse_core.m

net_param.generator  = 'gen_sparse_mt19937';
net_param.p          = 200;
net_param.sparseness = 40/net_param.p;  % 0.20 0.15 0.10 0.05
net_param.seed       = 423;
net_param.software   = 'MT19937';
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

b_use_spike_train = false;
i_stv   = 1;  % Down sampling factor

clear('pm');
pm.neuron_model = 'HH3_gcc49_westmere2';
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = round(0.2*net_param.p);
pm.scee = 0.05/2;
pm.scie = 0.05/2;
pm.scei = 0.10/2;
pm.scii = 0.10/2;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = 1e6;
pm.stv  = 0.5;

max_od = 40;
%return
%pm.t    = 1e3;
%[X, ISI, ras, pm] = gen_HH(pm, 'ext_T, new, rm');
%fprintf('mean ISI = %.2f (std=%.2f)\n', mean(ISI), std(ISI));
%addpath /home/xyy/matcode/prj_GC_clean/test_AIC_talk/
%ras_plot(ras, 0, 1000, 1:100);
%return;

%GCHH_analyse_core                 % 

net_param.sparseness = 10/net_param.p;
pm.net_param = net_param;
pm.net = gen_network(net_param);
GCHH_analyse_core                 % HH: 2.04 h, t = 192.013s cal GC.

net_param.sparseness = 20/net_param.p;
pm.net_param = net_param;
pm.net = gen_network(net_param);
GCHH_analyse_core                 % HH: 1.93 h, t = 569.666s cal GC.

net_param.sparseness = 40/net_param.p;
pm.net_param = net_param;
pm.net = gen_network(net_param);
GCHH_analyse_core                 % HH: 1.96 h, t = 169.728s cal GC.
