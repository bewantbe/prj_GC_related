% 

% common parameters for neuron network
pm = [];
pm.net = 'net_12_net2_2';
pm.nI   = 0;
pm.scee = 0.01;
pm.pr   = 12;
pm.ps   = 0.01;
pm.t    = 2e5;
pm.seed = 341892;
pm.extra_cmd = '--pr-mul 0.0033333333333 0.0033333333333';

%gen_HH(pm, 'new,ext_T,cmd');
%return

i_stv   = 1;
max_od = 30;
b_use_spike_train = true;

GCHH_analyse_core;

