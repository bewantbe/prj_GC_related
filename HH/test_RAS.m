% test accuracy of RAS

clear('pm');
pm.neuron_model = 'LIF_GH_icc';
pm.net  = 'net_100_01';
pm.nI   = 0;
pm.scee = 0.002;
pm.scie = 0.00;
pm.scei = 0.00;
pm.scii = 0.00;
pm.pr   = 1.0;
pm.ps   = 0.024;
pm.t    = 1e4;
pm.dt   = 1.0/32;
pm.stv  = 0.5;
pm.seed = 'auto';
pm.extra_cmd = '';
[X, ISI, ras] = gen_HH(pm, 'new');
%[X, ISI, ras] = gen_HH(pm, 'new,extT');

[p, len] = size(X);

s_t = 1;

%plot(X)
