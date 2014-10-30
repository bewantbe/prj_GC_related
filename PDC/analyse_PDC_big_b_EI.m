
% common parameters for network
net_param.generator  = 'gen_sparse';
net_param.p          = 100;
net_param.sparseness = 0.05;  % 0.20 0.15 0.10 0.05
net_param.seed       = 123;
net_param.software   = myif(exist('OCTAVE_VERSION','builtin'), 'octave', 'matlab');
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

% common parameters for neuron network
pm = [];
pm.neuron_model = 'LIF_icc';
pm.nI   = 20;
pm.scee = 0.004;
pm.scie = 0.004;
pm.scei = 0.007;
pm.scii = 0.007;
pm.pr   = 1.0;
pm.ps   = 0.007;
pm.t    = 1e6;
pm.stv  = 0.5;

% sub-case 4, 20% connectivity, EI
net_param.sparseness = 0.20;
pm.net_param = net_param;
pm.net = gen_network(net_param);
X = gen_HH(pm, 'ext_T');

analyse_PDC_big_p_core;
