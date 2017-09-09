addpath('/home/xyy/matcode/prj_GC_clean/HH/scan_worker/');

% scan for
s_pr_ps = linspace(0.7, 4.0, 20);
ps_mV = 0.5;

% fixed parameters
pm.neuron_model = 'HH-GH';
pm.net     = 'net_2_2';
pm.scee_mV = 1.0;
%pm.pr    = s_pr_ps(1) ./ ps_mV;
%pm.ps_mV = ps_mV;
pm.t    = 1e5;
pm.stv  = 0.5;
pm.extra_cmd = '';

scan_all_worker_head;
