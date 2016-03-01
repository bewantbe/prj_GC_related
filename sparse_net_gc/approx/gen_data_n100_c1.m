%

simu_time = 1e6;
p = 100;

pm = [];
pm.neuron_model = 'HH3_gcc49_westmere2_nogui';
pm.net  = 'net_100_0X3CC7CFD0';
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
%pm.extra_cmd = '-q';

[X, ISI, ras, pm] = gen_HH(pm, 'ext_T', '../worker/data/');

