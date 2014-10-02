% Generate HH data
% work with GCHH_analyse_core.m

net_param.generator  = 'gen_sparse';
net_param.p          = 400;
net_param.sparseness = 0.05;  % 0.20 0.15 0.10 0.05
net_param.seed       = 123;
net_param.software   = myif(exist('OCTAVE_VERSION','builtin'), 'octave', 'matlab');
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

i_stv   = 1;  % Down sampling factor

clear('pm');
pm.neuron_model = 'HH3_gcc';
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = 20;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.09;
pm.scii = 0.09;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = 1e6;
pm.stv  = 0.5;

max_od = 40;

%[X, ISI, ras, pm] = gen_HH(pm, 'ext_T, new, rm');
%return;

b_use_spike_train = true;

GCHH_analyse_core                 % cost 25.36h, t = 8063.150s cal GC.

net_param.sparseness = 0.10;
pm.net_param = net_param;
pm.net = gen_network(net_param);
GCHH_analyse_core                 % cost 30.52h, t = 7424.370s cal GC.

net_param.sparseness = 0.15;
pm.net_param = net_param;
pm.net = gen_network(net_param);
GCHH_analyse_core                 % cost 30.29h, t = 7256.533s cal GC.

net_param.sparseness = 0.20;
pm.net_param = net_param;
pm.net = gen_network(net_param);
GCHH_analyse_core                 % cost 30.06h, t = 7407.131s cal GC.

