% sub net reconstruction.

% input: R, p_val

addpath('~/matcode/prj_GC_clean/sparse_net_gc/');

auto_gc_zero_cut = false;
neu_network = net_connect;
R3d = reshape(R, p, p, []);

s_sub_p = [5 10 20 20 20 50 50 50 100 100 100 200 500];
%s_sub_p = [2 2 2 5 5 5 10 10 10];
a = zeros(size(s_sub_p,2), 2);
for id_sub_p = 1:length(s_sub_p) % [20 50 100 200 500 800]
  sub_p = s_sub_p(id_sub_p);
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

  a(id_sub_p, 1) = sub_p;
  a(id_sub_p, 2) = p_correct;

%  tic
%  sub_GC = pairRGrangerT(sub_R);
%  toc

%  disp('==================== pair GC ====================');
%  gc_zero_cut = gc_pval_choose(sub_GC, use_od, sub_neu_network, sub_p, len, p_val, auto_gc_zero_cut);
%  p_correct = gc_net_quality(sub_GC, gc_zero_cut, sub_neu_network, sub_p);

  fprintf('\n\n');
end

figure(10);
semilogx(a(:,1), a(:,2:end), '*');
set(gca, 'fontsize', 20);
xlabel('p in subnet');
ylabel('correctness');
legend('condGC');
%legend('location', 'northwest');
pic_output([pic_name_pre 'subnet_scan']);

