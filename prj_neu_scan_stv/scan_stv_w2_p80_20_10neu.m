% scan stv
% save some simple analyse results to .mat
% constant data length
t0=tic();
tocs = @(st) fprintf('%s: t = %6.3fs\n', st, toc());

% _ST _expIF
signature = 'data_scan_stv/IF_net_100_rs01_w2_p80_20_10neu';     % to distinguish different parallel program instances (also dir)

%s_ps_default = [0.001:0.001:0.029];  %29

% scan value sets
s_net  = {'net_100_rs01'};
s_time = [1e6];
s_scee = {[0.005, 0.005, 0.007, 0.007]};
s_prps = [0.012];
s_ps   = [0.012];
s_stv  = [0.5:0.5:30];
maxod  = 20;
s_od   = 1:maxod;
hist_div = 0:0.5:200;         % ISI
T_segment = 1000;             % in ms
stv0   = 0.5;               % fine sample rate
pE = 80;
pI = 20;

s_neu_id = [1:10];

save('-v7', [signature, '_info.mat'], 's_net', 's_time', 's_scee',...
     's_prps', 's_ps', 's_stv', 's_od', 'hist_div', 'maxod',...
     'T_segment','stv0','s_neu_id','pE','pI');

data_path = ['data/', signature, '_'];

% source the big loop here
scan_stv_worker_loop;

fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );

% vim: set ts=4 sw=4 ss=4
