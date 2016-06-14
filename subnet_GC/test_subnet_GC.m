%
pic_prefix = 'pic_tmp/';
pic_output = @(st)print('-depsc2',[pic_prefix, st, '.eps']);

addpath('/home/xyy/code/point-neuron-network-simulator/mfile/');
addpath('/home/xyy/matcode/GC_clean/GCcal/');

pm = [];
pm.prog_path = '/home/xyy/code/point-neuron-network-simulator/bin/gen_neu';
pm.neuron_model = 'HH-PT-GH';
PSP = neu_psp_test(pm);

randMT19937('seed', [12 3 3]);

pm.simu_method = 'SSC-Sparse';
pm.net  = randMT19937(1000)<0.2;
pm.nI   = 0;
pm.scee = 0.4 * PSP.mV_scee;
pm.scie = 0.4 * PSP.mV_scee;
pm.scei = 0.4 * PSP.mV_scei;
pm.scii = 0.4 * PSP.mV_scei;
pm.pr   = 2.0;
pm.ps   = 0.4 * PSP.mV_ps;
pm.t    = 1e3;
pm.dt   = 1.0/32;
pm.stv  = 0.5;
pm.seed = 'auto';
pm.extra_cmd = '';
tic
[X, ISI, ras] = gen_neu(pm, 'rm,new,ext_T');
toc
[p,  len] = size(X);

hd=ras_plot(ras);
pic_output('ras_tmp');

meanISI = mean(ISI)
minISI = min(ISI)

return

tic
use_od = chooseOrderAuto(X)
toc
tic
gc = nGrangerTfast(X, use_od);
toc

gc_prob_nonzero(gc, use_od, len)


