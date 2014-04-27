%

pm.net  = 'net_2_2';
pm.ps   = 0.04;
pm.pr   = 1.6;
pm.scee = 0.05;
pm.t    = 1e4;
pm.dt   = 1/32;
pm.stv  = 0.5;
[V, ISI, ras] = gen_HH(pm);
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

