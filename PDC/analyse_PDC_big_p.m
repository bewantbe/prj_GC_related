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

analyse_PDC_big_p_core;
