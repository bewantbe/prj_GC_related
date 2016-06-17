%
pic_prefix = 'pic_tmp/';
pic_output = @(st)print('-depsc2',[pic_prefix, st, '.eps']);

addpath('~/code/point-neuron-network-simulator/mfile/');
addpath('~/matcode/GC_clean/GCcal/');
addpath('~/matcode/GC_clean/prj_neuron_gc/');
addpath('~/matcode/prj_GC_clean/test_AIC_talk/');
addpath('~/matcode/prj_GC_clean/sparse_net_gc/worker/');  % for ras2SpikeTrainFile

pm_sparsenet_LIF_03;

size(net_connect)
sum(net_connect(:,1))
sum(net_connect(:))/(p*(p-1))

%net_connect_show = net_connect;
%net_connect_show(2:end,2:end) = 0;
%%adj2dot(net_connect, 'a', neu_coor*1/n_r);
%adj2dot(net_connect_show, 'a', neu_coor*1/sqrt(n_r));

tic
gen_neu(pm, 'ext_T');
toc
%return

if 0
% in-RAM analyse
%  [X, ISI, ras, pm] = gen_neu(pm, 'rm,new,ext_T');
  [X, ISI, ras, pm] = gen_neu(pm, 'ext_T');
  meanISI = mean(ISI)
  minISI = min(ISI)
  [p,  len] = size(X);
  X = SpikeTrainsFast(ras, p, len, pm.stv);

  hd=ras_plot(ras);
  pic_output('ras_tmp');

  tic
  use_od = chooseOrderAuto(X)
  toc
  tic
  gc = nGrangerTfast(X, use_od);
  toc
else

  tic
  [f_X, ISI, ras, pm] = gen_neu(pm, 'nameX,ext_T');
  toc
  path_ST = strrep(f_X, '_volt_', '_ST_');
  % save ras to fname as spike train
  tic
  ras2SpikeTrainFile(ras, p, floor(pm.t/pm.stv), pm.stv, path_ST);
  toc

  use_od = 100;
  tic
  R = getcovpdFile(path_ST, p, use_od);  % 1459 s, p=900, od=40, L= 2e6
  toc

  tic
  gc = RGrangerTLevinson(R);  % 188.9
  toc
  
  len = floor(pm.t/pm.stv);
  tic
  nonzero_prob = gc_prob_nonzero(gc, use_od, len);
  toc
  
  p_val = 1e-3;
  sum(sum(abs(net_connect  - (nonzero_prob>1-p_val))))/(p*(p-1))

  pic_name_pre = 'net_900_subnettest1_LIF_GH';

  figure(10);
  imagesc((nonzero_prob>1-p_val) - net_connect);
  caxis([-1 1]);
  xlabel('neuron id (from)');
  ylabel('neuron id (to)');
  pic_output([pic_name_pre '_cmp']);
  
  figure(20);
  hist(gc(eye(p)==0)*1e4, 1000);
  ylim([0 200]);
  xlabel('GC value (1e-4)');
  ylabel('count (per bin)');
  pic_output([pic_name_pre '_hist_gc']);

%  figure(21);
%  hist(nonzero_prob(eye(p)==0), 100);
%  ylim([0 10000]);
%  pic_output([pic_name_pre '_hist_gc']);

  figure(22);
  hd=ras_plot(ras, 1000, 2000);
  set(hd, 'linewidth', 2);
  xlabel('t (ms)');
  ylabel('neuron id');
  pic_output([pic_name_pre '_ras']);


end

return

gc
nonzero_prob = gc_prob_nonzero(gc, use_od, len)
