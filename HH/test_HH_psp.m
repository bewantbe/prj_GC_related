%

clear('pm');
pm.neuron_model = 'HH3_gcc49_westmere2';  %
pm.net  = 'net_2_2';
pm.scee = 0.05;
pm.pr   = 0.0;
pm.ps   = 0.03;
pm.t    = 1e5;
pm.stv  = 0.5;
pm.seed = 1256725;

max_od = 40;

[X, ISI, ras, pm] = gen_HH(pm, 'ext_T,rm');

