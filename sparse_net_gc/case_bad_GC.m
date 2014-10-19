% 

[ii, jj] = meshgrid(1:100, 1:100);
net = 1*(abs(ii - jj) < 20);
net(eye(100)==1) = 0;

net(80, 81) = 0;  % set to zero, but could be not zero
net(50, 51) = 0;  % set to zero

% normal point, zero
net(75, 95) = 0;

% normal point, non-zero
net(13, 1) = 1;  % but could looks small, inverse could looks big
net(92, 73) = 1;  % but could looks small, inverse could looks big
net(55, 56) = 1;  % normal

%% obfuscate^TM
%rand('state',3);
%rp = randperm(100);
%net(rp, rp) = net;

%fprintf(' \n');
%fprintf('%d, %d\n', rp(80), rp(81));
%fprintf('%d, %d\n', rp(50), rp(51));
%fprintf('%d, %d\n', rp(75), rp(95));
%fprintf('%d, %d\n', rp(13), rp(1));
%fprintf('%d, %d\n', rp(92), rp(73));
%fprintf('%d, %d\n', rp(55), rp(56));
%fprintf(' \n');

%13, 41
%36, 7
%52, 46
%86, 24
%37, 81
%51, 63

%sum(net(:))/numel(net)

% common parameters for neuron network
pm = [];
pm.neuron_model = 'LIF_icc';
pm.net_param = 'regular_sub_01';
pm.net = net;
pm.nI   = 0;
pm.scee = 0.004;
pm.pr   = 1.0;
pm.ps   = 0.007;
pm.t    = 1e6;
pm.seed = 341892;

pm.scee = 0.0055;
pm.ps   = 0.003;

%pm.extra_cmd = '';
%gen_HH(pm, 'new,ext_T,cmd');
%return

i_stv   = 1;
max_od = 30;
b_use_spike_train = true;

GCHH_analyse_core;

