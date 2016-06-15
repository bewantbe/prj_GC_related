%
pic_prefix = 'pic_tmp/';
pic_output = @(st)print('-depsc2',[pic_prefix, st, '.eps']);

addpath('~/code/point-neuron-network-simulator/mfile/');
addpath('~/matcode/GC_clean/GCcal/');
addpath('~/matcode/GC_clean/prj_neuron_gc/');
addpath('~/matcode/prj_GC_clean/test_AIC_talk/');

pm = [];
pm.prog_path = '/home/xyy/code/point-neuron-network-simulator/bin/gen_neu';
%pm.neuron_model = 'HH-PT-GH';
%PSP = neu_psp_test(pm);
%pm.scee = 0.2 * PSP.mV_scee;
%pm.scie = 0.2 * PSP.mV_scee;
%pm.scei = 0.2 * PSP.mV_scei;
%pm.scii = 0.2 * PSP.mV_scei;
%pm.pr   = 2.0;
%pm.ps   = 0.5 * PSP.mV_ps;

pm.neuron_model = 'LIF-GH';
PSP = neu_psp_test(pm);
pm.scee = 0.12 * PSP.mV_scee;
pm.scie = 0.12 * PSP.mV_scee;
pm.scei = 0.2 * PSP.mV_scei;
pm.scii = 0.2 * PSP.mV_scei;
pm.pr   = 2.0;
pm.ps   = 0.4 * PSP.mV_ps;

randMT19937('seed', [12 3 3]);

n_r = 30;  % number of row (y)
n_c = 30;  % number of column (x)
p = n_r * n_c;

% the networks
neu_coor = bsxfun(@times, randMT19937(p, 2), [n_c*20, n_r*20]);  % unit: um
dis_mat = ...% 
sqrt( ...
  bsxfun(@minus, neu_coor(:, 1), neu_coor(:, 1)').^2 ...
+ bsxfun(@minus, neu_coor(:, 2), neu_coor(:, 2)').^2);

%1e4*exp(-dis_mat) ./ dis_mat;

net_connect = exp(-dis_mat/150) > randMT19937(size(dis_mat));
net_connect(eye(length(net_connect))==1) = 0;

size(net_connect)
sum(net_connect(:,1))
sum(net_connect(:))/(p*(p-1))

net_connect_show = net_connect;
net_connect_show(2:end,2:end) = 0;
%adj2dot(net_connect, 'a', neu_coor*1/n_r);
adj2dot(net_connect_show, 'a', neu_coor*1/sqrt(n_r));

%return

pm.net = net_connect .* (1+0.1*randn(size(net_connect)));
pm.nI  = 250;

%pm.net  = randMT19937(1000)<0.2;
%pm.nI   = 250;

%pm.net  = [0 1; 0 0];
%pm.nI   = 0;

pm.simu_method = 'SSC-Sparse';
pm.t    = 2e6;
pm.dt   = 1.0/32;
pm.stv  = 1.0;
pm.seed = 'auto';
tic
%[X, ISI, ras, pm] = gen_neu(pm, 'rm,new,ext_T');
gen_neu(pm, 'ext_T');
toc
return

[p,  len] = size(X);
X = SpikeTrainsFast(ras, p, len, pm.stv);

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

gc
nonzero_prob = gc_prob_nonzero(gc, use_od, len)


