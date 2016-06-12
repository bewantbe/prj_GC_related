%

%'GCinfo_HH3_gcc49_sparse_ST_net_1000_0X51879353_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40';

gcdata_name =...
'GCinfo_HH3_gcc_net_200_0X26E90012_p=180,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40';

p_val = 1e-5;
use_od = 40;
auto_gc_zero_cut = false;

gcdata_dir       = 'GCinfo/';
load([gcdata_dir, gcdata_name, '.mat']);

  neu_network = pm.net_adj;
  p = size(neu_network, 1);
  nE = pm.nE;
  nI = pm.nI;
  if any(diag(neu_network))
    error('neu_network: diagonal non-zero!');
  end

pic_output = @(st)print('-depsc2',[pic_prefix, st, '.eps']);

%  GC = oGC(:,:,use_od);
  R3d = reshape(R, p, p, []);

  id_subnet = 1:100;
  sub_p = length(id_subnet);
  sub_neu_network = neu_network(id_subnet, id_subnet);
  sub_R = reshape(R3d(id_subnet,id_subnet,:), sub_p, []);

  tic;
  sub_GC = RGrangerTfast(sub_R);
%  sub_GC = pairRGrangerT(sub_R);
  toc;

%  gc_net_quality(GC, use_od, neu_network, nE, nI, p_val);

gc_zero_cut = gc_pval_choose(sub_GC, use_od, sub_neu_network, sub_p, len, p_val, auto_gc_zero_cut);
p_correct = gc_net_quality(sub_GC, gc_zero_cut, sub_neu_network, sub_p);

