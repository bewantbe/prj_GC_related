% chi-square distribution
pic_common_include;

len = 1e5;
m = 5;
gc_scale = 1e-3;  % plot GC in this scale
x_max = m + 9*sqrt(m);

gc1 = 0.0002;
alpha_val = 0.05;
gc_cut = chi2inv(1-alpha_val, m)/len;

s_x = linspace(0, x_max, 500);

s_ncc0 = chi2_pdf(s_x, m, 0)*len*gc_scale;
s_x = s_x / len / gc_scale;

figure(1);
rg0 = s_x < gc_cut/gc_scale;
rg1 = s_x >= gc_cut/gc_scale;
area(s_x(rg0), s_ncc0(rg0), 'facecolor', [0.7 1 0.7], 'linewidth', 0);
hold on
area(s_x(rg1), s_ncc0(rg1), 'facecolor', [0.68 0.79 1], 'linewidth', 0);
%haxp = plot(s_x, s_ncc1, s_x, s_ncc0);
hold off
x_max = x_max/len/gc_scale;
y_max = chi2pdf(m-2,m)*len*gc_scale;
haxl = line(gc_cut/gc_scale*[1 1]', [0,0.6*y_max]', 'color','black', 'linestyle', '--');
hd=legend(haxl, ['GC_{thres}(\alpha = ' sprintf('%.3f)',alpha_val)]);
haxl = line(gc1/gc_scale*[1 1]', [0,0.6*y_max]', 'color','black', 'linestyle', '-');
hd=legend(haxl, ['GC1']);
%legend(sprintf('GC_{thres}(\alpha = %.3f)',alpha_val));
%legend(haxl, 'GC \alpha = 12321');
%set(hd, 'fontsize', fontsize-2);
xlabel(sprintf('GC (/ %.1e)', gc_scale));
ylabel(sprintf('pdf_{%d, %.1e, F}(x)',m,len));
xlim([0, x_max]);
ylim([0, y_max*1.1]);
xl = xlim();
pic_output_color(sprintf('pdf_m=%d_L=%2.e_F0_alpha', m, len));

