%


T = 1e6;
pm = [];              % a new parameter set
pm.neuron_model = 'LIF_icc';  % program to run, with prefix raster_tuning_
pm.net  = 'net_100_01';  % can also be a connectivity matrix of full file path
pm.nI   = 0;          % default: 0. Number of Inhibitory neurons.
pm.scee = 0.005;
pm.scie = 0.00;       % default: 0. Strength from Ex. to In.
pm.scei = 0.00;       % default: 0. Strength from In. to Ex.
pm.scii = 0.00;       % default: 0.
pm.pr   = 0.24;
pm.ps   = 0.02;
pm.t    = T;
pm.dt   = 1.0/32;     % default: 1/32
pm.stv  = 0.5;        % default: 0.5
pm.seed = 'auto';     % default: 'auto'(or []). Accept integers
pm.extra_cmd = '';    % default: '--RC-filter 0 1'

X = gen_HH(pm, 'new,ext_T', data_dir_prefix);

[oGC, oDe, R] = AnalyseSeriesFast(X, s_od);
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);

od = bic_od;
fftlen = 1024;

pdc = PDC(X, od, fftlen);

f_sm = @(x) real(mean(x.*x,3));
pdc_sm = f_sm(pdc);
pdc_max = max(abs(pdc), [], 3);

