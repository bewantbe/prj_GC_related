%
pic_common_include;

simu_time = 1e5;
stv = 0.5;
len = simu_time/stv;
F1 = 1.57e-4;  % GC1: 1, 0.012, 0.01
%F1 = 1.36e-4;  % GC1: 0.24, 0.02, 0.01
%F1 = 3.25e-4;  % GC1: 1, 0.006, 0.01
F1 = F1*2*stv;
gc_scale = 1e-4;  % plot GC in this scale

m = 17;
c = len*F1;
ncc_mean = m+c
ncc_var  = 2*m + 4*c
x_max = ncc_mean+3.9*sqrt(ncc_var);
s_x = linspace(0, x_max, 5000);

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
haxl = line(gc_cut/gc_scale*[1 1]', [0,1.1*y_max]', 'color','black');
hd=legend(haxp, sprintf('GC1(F=%.2e)',F1), 'GC0');
hd=legend(haxl, sprintf('GC_{thres}(p=%.3f)',p_val));
set(hd, 'fontsize', fontsize-2);
%plot_mbar(m, c);
%plot_mbar(m, 0);
xlabel(sprintf('GC / %.2e', gc_scale));
ylabel('pdf');
%xlim([0, x_max]);
ylim([0, y_max*1.1]);
pic_output_color(sprintf('pdf_m=%d_L=%2.e_F0_F1=%.2e', m, len, F1));

