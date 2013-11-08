%
pic_common_include;

simu_time = 1e5;
stv = 0.5;
len = simu_time/stv;
F1 = 1.592e-4;  % GC1: 1, 0.012, 0.01
%F1 = 1.68e-4;  % GC1: 1, 0.012, 0.01, looks like from L=1e5
%F1 = 1.36e-4;  % GC1: 0.24, 0.02, 0.01
%F1 = 3.25e-4;  % GC1: 1, 0.006, 0.01
F1 = F1*2*stv;
gc_scale = 1e-4;  % plot GC in this scale

m = 17;
c = len*F1;
ncc_mean = m+c
ncc_var  = 2*m + 4*c
x_max = ncc_mean+3.9*sqrt(ncc_var);
s_x = linspace(0, x_max, 500);

s_ncc1  = chi2_pdf(s_x, m, c)*len*gc_scale;
s_ncc0 = chi2_pdf(s_x, m, 0)*len*gc_scale;
s_x = s_x / len / gc_scale;

% test
p_val = 1e-2;
gc_cut = chi2inv(1-p_val, m)/len
%gc_cut = 0.275e-3;
p_H0_significant = chi2_cdf(len*gc_cut, m, 0)
p_H1_nonsignificant = chi2_cdf(len*gc_cut, m, c)
% if independent
p_guess_correct = p_H0_significant * (1-p_H1_nonsignificant)

% plots
plot_mbar = @(m, c) line_mean_bar((m+c)/len/gc_scale, chi2_pdf(m+c, m, c)*len*gc_scale, sqrt(2*m+4*c)/len/gc_scale, 'color', 'red');

figure(1);  clf; cla;
hold on
rg0 = s_x < gc_cut/gc_scale;
rg1 = s_x > gc_cut/gc_scale;
area(s_x(rg1), s_ncc1(rg1), 'facecolor', [0.68 0.79 1], 'linewidth', 0);
area(s_x(rg0), s_ncc0(rg0), 'facecolor', [0.7 1 0.7], 'linewidth', 0);
haxp = plot(s_x, s_ncc1, s_x, s_ncc0);
hold off
x_max = x_max/len/gc_scale;
y_max = chi2pdf(m-2,m)*len*gc_scale;
haxl = line(gc_cut/gc_scale*[1 1]', [0,1.1*y_max]', 'color','black', 'linestyle', '--');
hd=legend(haxp, sprintf('GC1(F=%.2e)',F1), 'GC0');
hd=legend(haxl, sprintf('GC_{thres}(p=%.3f)',p_val));
set(hd, 'fontsize', fontsize-2);
%plot_mbar(m, c);
%plot_mbar(m, 0);
xlabel(sprintf('GC / %.1e', gc_scale));
ylabel(sprintf('pdf_{%d, %.1e, F}(x)',m,len));
%xlim([0, x_max]);
ylim([0, y_max*1.1]);
pic_output_color(sprintf('pdf_m=%d_L=%2.e_F0_F1=%.2e', m, len, F1));


figure(2);
load('s_gc_stat_od=17_L=2.0e+05_pr=1.0e+00_ps=1.2e-02_sc=1.0e-02.mat');
gc_scale = 1e-4;
n_bin = 50;
[nn1, xx1] = hist_pdf(s_gc_stat(:,1)/gc_scale, n_bin);
[nn0, xx0] = hist_pdf(s_gc_stat(:,2)/gc_scale, n_bin);
stairs([0, xx1], [0, nn1], 'color', [0.3 0.2 1]);
hold on
stairs([0, xx0], [0, nn0], 'color', [0 0.7 0]);
plot(s_x, s_ncc1, s_x, s_ncc0);
hold off
ylim([0, y_max*1.1]);
pic_output_color(sprintf('pdf_stat_m=%d_L=%2.e_F0_F1=%.2e', m, len, F1));

figure(3);
g_max    = 5;
nbins    = 40;
nn = hist2dnn(s_gc_stat(:,2)/gc_scale, s_gc_stat(:,1)/gc_scale, [0 g_max], nbins);
rg0 = g_max*(1:nbins+1)/nbins;
rg1 = g_max*(1:nbins+1)/nbins;
pcolor(rg0, rg1, [[nn, zeros(length(rg1)-1,1)]; zeros(1,length(rg0))]);
colormap(flipud(colormap('gray')));
shading('interp');
axis([0 g_max 0 g_max]);
line(gc_cut/gc_scale*[1 1], [0, g_max], 'linestyle', '--');
line([0, g_max], gc_cut/gc_scale*[1 1], 'linestyle', '--');
xlabel(sprintf('GC(x->y) / %.1e', gc_scale), 'interpreter', 'none');
ylabel(sprintf('GC(y->x) / %.1e', gc_scale), 'interpreter', 'none');
text(0.2, 0.4, 'wrong', 'fontsize', fontsize-4, 'color', 'red');
text(0.2, 2.4, 'wrong', 'fontsize', fontsize-4, 'color', 'red');
text(3.6, 0.4, 'correct', 'fontsize', fontsize-4, 'color', 'blue');
text(3.6, 2.4, 'wrong', 'fontsize', fontsize-4, 'color', 'red');
axis('square');
pic_output_color(sprintf('pdf_2d_stat_m=%d_L=%2.e_F0_F1=%.2e', m, len, F1));

figure(4);
s_g = g_max*(1:nbins)/nbins;
nn0 = sum(nn, 2)';
nn1 = sum(nn, 1);
nn01 = nn0'*nn1/sum(nn(:));
rg0 = g_max*(1:nbins+1)/nbins;
rg1 = g_max*(1:nbins+1)/nbins;
%pcolor(rg0, rg1, [[nn01, zeros(length(rg1)-1,1)]; zeros(1,length(rg0))]);
pcolor(rg0, rg1, [[(nn01-nn)/max(nn(:)), zeros(length(rg1)-1,1)]; zeros(1,length(rg0))]);
colorbar();
colormap(flipud(colormap('gray')));
shading('interp');
axis([0 g_max 0 g_max]);
axis('square');
%pbaspect([1 0.9]);
pic_output_color(sprintf('pdf_2d_stat_diff_m=%d_L=%2.e_F0_F1=%.2e', m, len, F1));

figure(5);
pcolor(rg0, rg1, [[(nn01)/max(nn(:)), zeros(length(rg1)-1,1)]; zeros(1,length(rg0))]);
colormap(flipud(colormap('gray')));
xlabel(sprintf('GC(x->y) / %.1e', gc_scale), 'interpreter', 'none');
ylabel(sprintf('GC(y->x) / %.1e', gc_scale), 'interpreter', 'none');
shading('interp');
axis([0 g_max 0 g_max]);
axis('square');
%pbaspect([1 0.9]);
pic_output_color(sprintf('pdf_2d_stat_fake_m=%d_L=%2.e_F0_F1=%.2e', m, len, F1));



stat_guess_correct = sum(s_gc_stat(:,1)>gc_cut & s_gc_stat(:,2)<gc_cut)/length(s_gc_stat)
