% input: p, n_indirect, simu_time
% output: X, ISI, ras, pm

sparseness = round(sqrt(p*n_indirect))/p

net_param = [];
net_param.generator  = 'gen_sparse_mt19937';
net_param.p          = p;
net_param.sparseness = sparseness;
net_param.seed       = 4563;
net_param.software   = 'MT19937';

gen_network = @(np) eval(sprintf('%s(np);', np.generator));

pm = [];
pm.neuron_model = 'HH3_gcc49_westmere2_nogui';
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = round(0.2*p);
pm.nE   = p - pm.nI;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.10;
pm.scii = 0.10;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = simu_time;
pm.stv  = 0.5;

[X, ISI, ras, pm] = gen_HH(pm, 'ext_T', '../worker/data/');

