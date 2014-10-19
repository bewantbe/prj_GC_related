% parameters to generate the network
net_param.generator  = 'gen_sparse';
net_param.p          = 1000;
net_param.sparseness = 0.025;  % 0.30 0.20 0.15 0.10 0.05
net_param.seed       = 123;
net_param.software   = myif(exist('OCTAVE_VERSION','builtin'), 'octave', 'matlab');
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

clear('pm');
pm.neuron_model = 'HH3_gcc49_s';
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = floor(net_param.p * 0.25);
pm.scee = 0.04;
pm.scie = 0.04;
pm.scei = 0.07;
pm.scii = 0.07;
pm.pr   = 0.7;
pm.ps   = 0.032;  % 0.032 = 1 mV
pm.t    = 1e3;
pm.stv  = 0.5;

[X2, ISI2, ras2] = gen_HH(pm, 'rm');  % ,ext_T
mean(ISI2)
var(ISI2)

