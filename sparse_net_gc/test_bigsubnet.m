%

%'GCinfo_HH3_gcc49_sparse_ST_net_1000_0X51879353_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40';

%gcdata_name = 'GCinfo_HH3_gcc_net_200_0X26E90012_p=180,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40';

%gcdata_name = 'GCinfo_HH3_gcc_net_200_0X26E90012_p=180,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40';

% 10%
%gcdata_name = 'GCinfo_HH3_gcc49_sparse_ST_net_1000_0X5EBBB38E_p=750,250_sc=0.03,0.03,0.1,0.1_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40';

% 5%
%gcdata_name = 'GCinfo_HH3_gcc49_sparse_ST_net_1000_0X756CC540_p=750,250_sc=0.03,0.03,0.1,0.1_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40';

% 20%
gcdata_name = 'GCinfo_HH3_gcc49_sparse_net_1000_0X39A0FE1E_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40';

p_val = 1e-5;
auto_gc_zero_cut = false;

gcdata_dir       = 'GCinfo/';
load([gcdata_dir, gcdata_name, '.mat'], 'R', 'pm', 'len', 'ISI');

f_R_long = [gcdata_dir, gcdata_name, '_R80.mat'];
if exist(f_R_long, 'file')
  load(f_R_long, 'R_long', 'pm');
  R = R_long;
else
% re gen R
% X = gen_HH(pm, 'read');  % 1000:70s,
% R_long = getcovpd(X, 80);  % 80: 3504.377081
% save([gcdata_dir, gcdata_name, '_R80.mat'], 'R_long', 'pm');
end

use_od = size(R, 2)/size(R, 1) - 1;

  neu_network = pm.net_adj;
  p = size(neu_network, 1);
  if any(diag(neu_network))
    error('neu_network: diagonal non-zero!');
  end

fprintf('Using od = %d\n', use_od);

pic_output = @(st)print('-depsc2',[pic_prefix, st, '.eps']);

%  GC = oGC(:,:,use_od);
  R3d = reshape(R, p, p, []);

for sub_p = 200 %[5 10 20 20 20 50 50 50 100 100 100 200 500] % [20 50 100 200 500 800]
  fprintf('subnet p = %d\n', sub_p);
  id_subnet = randperm(p, sub_p); % 1:200;
  sub_p = length(id_subnet);
  sub_neu_network = neu_network(id_subnet, id_subnet);
  sub_R = reshape(R3d(id_subnet,id_subnet,:), sub_p, []);

  tic
  %sub_GC = RGrangerTfast(sub_R);
  sub_GC = RGrangerTLevinson(sub_R);
  toc

  disp('================ conditional GC ================');
  gc_zero_cut = gc_pval_choose(sub_GC, use_od, sub_neu_network, sub_p, len, p_val, auto_gc_zero_cut);
  p_correct = gc_net_quality(sub_GC, gc_zero_cut, sub_neu_network, sub_p);

%  tic
%  sub_GC = pairRGrangerT(sub_R);
%  toc

%  disp('==================== pair GC ====================');
%  gc_zero_cut = gc_pval_choose(sub_GC, use_od, sub_neu_network, sub_p, len, p_val, auto_gc_zero_cut);
%  p_correct = gc_net_quality(sub_GC, gc_zero_cut, sub_neu_network, sub_p);

  fprintf('\n\n');
end

