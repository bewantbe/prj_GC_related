%

clear('pm');
pm.net  = 'net_1_0';
pm.ps   = 1/31 * 1/1;
pm.pr   = 0.1/pm.ps;
pm.scee = 0.01;
pm.t    = 1e4;
pm.stv  = 0.5;
[V, ISI, ras] = gen_HH(pm, 'rm');
p = size(V,1);
ST = SpikeTrains(ras, p, round(pm.t/pm.stv), pm.stv);

rg_inc = 100;
rg_bg = 1000;
rg_ed = rg_bg+rg_inc-1;
rg_idxs = 1:rg_inc;
figure(1);
plot(rg_idxs, V(1, rg_bg:rg_ed), rg_idxs, ST(1, rg_bg:rg_ed));

od = 20;
gc = nGrangerT(V, od)

