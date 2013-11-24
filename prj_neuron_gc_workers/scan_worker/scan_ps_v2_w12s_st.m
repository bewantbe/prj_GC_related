% scan: fix ps

% scan every thing (length - network - scee - ps - pr*ps - stv)
% save some simple analyse results to .mat

% to distinguish different parallel program instances (also dir)
signature = 'data_scan_ps/v2_w12s_st';

% scan value sets
s_net  = {'net_2_2'};
s_time = [1e7];
s_scee = [0.01];
s_prps = 0.005*(logspace(log10(0.80-0.6),log10(1.1-0.6), 30)+0.6);
s_ps   = 0.005;  % pr=0.80:ISI=15000, pr=1.1:ISI=180
s_stv  = 1/2;

maxod  = 99;
s_od   = 1:maxod;
hist_div = 0:20:10000;          % ISI

extst = '-q';

ncpu = 15;
scan_ps_v2_loop;
