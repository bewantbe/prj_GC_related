%

simu_time = 1e5;
stv = 0.5;
len = simu_time/stv;
F1 = 0.157e-3;  % GC1: 1, 0.012, 0.01
%F1 = 0.136e-3*2*stv;  % GC1: 0.24, 0.02, 0.01
%F1 = 0.325e-3;  % GC1: 1, 0.006, 0.01
F1 = F1*2*stv;
gc_scale = 1e-3;  % plot GC in this scale

m = 22;
c = len*F1;
ncc_mean = m+c
ncc_var  = 2*m + 4*c
s_x = linspace(0, ncc_mean+3*sqrt(ncc_var), 5000);

s_ncc  = chi2_pdf(s_x, m, c)*len*gc_scale;
s_ncc0 = chi2_pdf(s_x, m, 0)*len*gc_scale;
s_x = s_x / len / gc_scale;

% test
p_val = 5e-2;
gc_cut = chi2inv(1-p_val, m)/len
%gc_cut = 0.275e-3;
p_H0_significant = chi2_cdf(len*gc_cut, m, 0)
p_H1_nonsignificant = chi2_cdf(len*gc_cut, m, c)
% if independent
p_guess_correct = p_H0_significant * (1-p_H1_nonsignificant)

% plots
plot_mbar = @(m, c) line_mean_bar((m+c)/len/gc_scale, chi2_pdf(m+c, m, c)*len*gc_scale, sqrt(2*m+4*c)/len/gc_scale, 'color', 'red');
%line_mean_bar(ncc_mean, chi2_pdf(ncc_mean, m, c), sqrt(ncc_var), 'color', 'red');

figure(1);
plot(s_x, s_ncc, s_x, s_ncc0);
line(gc_cut/gc_scale*[1 1]', [0,1.1*chi2pdf(m-2,m)*len*gc_scale]', 'color','black');
legend('GC1','GC0', sprintf('GC threshold - p = %.3f',p_val));
%plot_mbar(m, c);
%plot_mbar(m, 0);
xlabel(sprintf('GC / %.2e', gc_scale));
ylabel('pdf');

