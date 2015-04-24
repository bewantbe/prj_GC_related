% run this in Octave

gcdata_dir  = 'GCinfo/';

gcdata_name = 'GCinfo_HH3_gcc_net_50_0X7F4447F6_p=30,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40';

load([gcdata_dir, gcdata_name, '.mat'], 'pm');

% get data
[~, ~, ras, pm] = gen_HH(pm, 'ext_T');
p = pm.nE + pm.nI;

% cut data
time_end = 1000;
local_ras = ras(ras(:,2) < time_end/pm.stv, :);

id_neu = 1 : p;
%id_neu = 1:200;  % select the neurons that you want to plot
id_b_neu = false(1, p);
id_b_neu(id_neu) = true;
local_ras = local_ras(id_b_neu(local_ras(:,1)), :);

disp('ploting');  fflush(stdout);
tic();
% plot data
    is_octave = exist('OCTAVE_VERSION','builtin') ~= 0;
    if is_octave
        fontsize = 20;
        linewidth = 1;
    else
        fontsize = 16;
        linewidth = 1;
    end
    pic_prefix = 'pic_tmp/';
    pic_output       = @(st)print('-deps',  [pic_prefix, st, '.eps']);
    pic_output_color = @(st)print('-depsc2',[pic_prefix, st, '.eps']);
    set(0, 'defaultlinelinewidth', linewidth);
    set(0, 'defaultaxesfontsize', fontsize);
    set(0, 'defaultfigurevisible', 'off');

figure(1);
cla
clf
plot(0,0);
line([local_ras(:, 2)'*pm.stv; local_ras(:, 2)'*pm.stv],...
     [local_ras(:, 1)'; local_ras(:, 1)'-0.8], 'color', [0 0 0]);
xlabel('time (ms)');
ylabel('neuron id');
axis([0, time_end, min(id_neu)-1, max(id_neu)]);
pic_output_color(sprintf('raster_n=%d,%d_%s_%.1f%%_pr=%.1f_ps=%.3f_showN=%d',...
  pm.nE, pm.nI, pm.net, 100*sum(pm.net_adj(:))/p/(p-1), pm.pr, pm.ps, numel(id_neu)));
toc
