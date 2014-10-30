% for analyse_PDC_big_p.m

[X, ~, ~, pm] = gen_HH(pm, 'new,ext_T');
[p, len] = size(X);

% GC
s_od = 1:30;
[oGC, oDe, R] = AnalyseSeriesFast(X, s_od);
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);

% PDC
od = bic_od;
fftlen = 1024;
pdc = PDC(X, od, fftlen);
f_sm = @(x) real(mean(x.*x,3));
pdc_sm = f_sm(pdc);
pdc_max = max(abs(pdc), [], 3);

save('-v7', 'ex_PDC_net_100.mat', pm, 'oGC', 'oDe', 'R', 'pdc');
