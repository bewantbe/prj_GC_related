
load('ex_PDC_net_100_EI.mat');

s_od = 1:30;
len = 2e6;
p = 100;
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);

f_sm = @(x) real(mean(x.*x,3))(eye(p)==0);
pdc_sm = f_sm(pdc);
pdc_max = max(abs(pdc), [], 3)(eye(p)==0);
p = size(zero_GC, 1);

od = aic_od;
gc_plain = oGC(:,:,od);
gc_plain(eye(p)==1) = [];

figure(1);
plot(sort(gc_plain));

figure(2);
plot(sort(pdc_sm));

figure(3);
plot(sort(pdc_max));

