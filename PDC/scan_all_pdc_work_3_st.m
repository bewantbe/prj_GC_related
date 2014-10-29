% scan every thing (length - network - scee - ps - pr*ps - stv)
% save some simple analyse results to .mat
% constant data length
tic();

signature = 'data_scan_IF/pdc_w3';     % to distinguish different parallel program instances (also dir)

% scan value sets
s_net  = {'net_2_2'};
s_time = [1e6];
s_scee = [0.01];
prps_base = 0.004;
s_prps = prps_base + logspace(log10(0.005-prps_base), log10(0.04-prps_base), 21);  % use 21 or 11 points
s_ps   = logspace(log10(0.001), log10(0.02), 21);
s_stv  = [0.5];  s_dt   = 1.0/32;
maxod  = 99;
s_od   = 1:maxod;
hist_div = 0:0.5:200;          % ISI
b_use_spike_train = true;
fftlen = 1024;

scan_all_pdc_worker_core_IF;

toc();

%exit
