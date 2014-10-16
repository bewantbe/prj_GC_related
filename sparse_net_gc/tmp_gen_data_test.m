% parameters to generate the network
net_param.generator  = 'gen_sparse';
net_param.p          = 100;
net_param.sparseness = 0.15;  % 0.30 0.20 0.15 0.10 0.05
net_param.seed       = 123;
net_param.software   = myif(exist('OCTAVE_VERSION','builtin'), 'octave', 'matlab');
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

clear('pm');
pm.neuron_model = 'HH3_gcc';
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = net_param.p * 0.2;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.09;
pm.scii = 0.09;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = 1e3;
pm.stv  = 0.5;

[X2, ISI2, ras2] = gen_HH(pm, 'rm');


