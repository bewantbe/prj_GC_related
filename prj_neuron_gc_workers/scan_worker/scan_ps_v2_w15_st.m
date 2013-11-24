% scan: fix ps

% scan every thing (length - network - scee - ps - pr*ps - stv)
% save some simple analyse results to .mat

% to distinguish different parallel program instances (also dir)
signature = 'data_scan_ps/v2_w15_st';

% scan value sets
s_net  = {'net_2_2'};
s_time = [1e7];
s_scee = [0.01];
s_prps = 0.9*[0.005:0.00025:0.00725, 0.0075:0.0005:0.0095, 0.01:0.001:0.019, 0.02:0.002:0.04];
s_ps   = 0.02;
s_stv  = 1/2;

maxod  = 99;
s_od   = 1:maxod;
hist_div = 0:0.5:200;          % ISI

extst = '-q';

ncpu = 10;
scan_ps_v2_loop;
