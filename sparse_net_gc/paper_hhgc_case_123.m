% case of 1 -> 2 -> 3

%pm.neuron_model = 'HH3_gcc49';
pm.neuron_model = 'HH3_gcc49_native';
pm.net  = 'net_3_03';
pm.nE   = 3;
pm.scee = 0.05;
pm.pr   = 2.0;
pm.ps   = 0.03;
pm.t    = 1e6;
pm.stv  = 0.5;

[X, ISI, ras, pm] = gen_HH(pm, 'ext_T');

od = chooseOrderAuto(X, 'aic');
gc = nGrangerT(X, od)

len = size(X, 2);
gc_pz = gc_prob_nonzero(gc, od, len)


gcp = pairGrangerT(X, od)
gcp_pz = gc_prob_nonzero(gc, od, len)
