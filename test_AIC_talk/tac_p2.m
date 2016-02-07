% Show voltage trace and raster plot

pic_common_include;
%addpath('../HH');
disp('----------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate data
addpath('/home/xyy/code/point-neuron-network-simulator/mfile');

pm = [];
%pm.neuron_model = 'HH-GH';  % one of LIF-G, LIF-GH, HH-GH
pm.neuron_model = 'LIF-G';
%pm.net  = 'net_3_06';
pm.net  = 'net_5_1';
pm.nI   = 0;
pm.scee = 0.010;
pm.scie = 0.00;
pm.scei = 0.00;
pm.scii = 0.00;
pm.pr   = 1.0;
pm.ps   = 0.012;
pm.t    = 1e5;
pm.dt   = 1.0/32;
pm.stv  = 0.5;
pm.seed = 2333;
pm.extra_cmd = '';
[X, ISI, ras, pm] = gen_neu(pm, 'new');

mode_IF = pm.neuron_model;
mode_ST = 0;

for id_p = 1:size(X,1)
  ISI(id_p) = pm.t/(sum(ras(:,1)==id_p,1));
end

[p, len] = size(X);
fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
 pm.net, pm.scee, pm.pr, pm.ps, pm.t, pm.stv, len);
disp('ISI:');
disp(ISI);

%max_od = 60;
%[zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od);

%GC_regression;

adj2dot(pm.net_adj, [pic_prefix pm.net]);

figure(1);
set(gca, 'fontsize', fontsize);
ras_plot(ras, 1000, 1100);
pic_output([pm.neuron_model '-ras-example']);

j_bg = round(1000/pm.stv);
j_rg = j_bg+round((0:100)/pm.stv);
figure(3);
plot(pm.stv*(j_rg-j_bg), bsxfun(@plus, X(:, j_rg), (1:p)'-1));
set(gca, 'fontsize', fontsize);
xlabel('time (ms)');
ylabel('voltage');
pic_output([mode_IF 'LIF-G-volt-example.eps']);

% net 2 adjacency matrix
figure(2);
imagesc(pm.net_adj);
colormap(flipud(gray()));
nx = 5;
ny = 5;
pbaspect([nx ny 1]);
set(gca,'xtick', linspace(0.5,nx+0.5,nx+1), 'ytick', linspace(0.5,ny+.5,ny+1));
set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');
pic_output([pm.net 'adj']);

figure(4);
adj2adjmatrix(pm.net_adj);
pic_output([pm.net 'adj2']);
pic_output_png([pm.net 'adj2']);
