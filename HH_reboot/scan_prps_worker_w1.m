% scan for pr and ps, with uniform firing rate along x-axis.
addpath('/home/xyy/matcode/prj_GC_clean/HH/scan_worker/');

ngrid_x = 40;
ngrid_y = 40;

%10x10
%t = 1e5;
%core = 4;
%124.9

s_ps_mV = linspace(0.05, 2.0, ngrid_y);  % the y-axis
s_pr_2d = zeros(numel(s_ps_mV), ngrid_x);

fr_request = linspace(1, 80, ngrid_x);

for k = 1 : numel(s_ps_mV)
  s_pr_2d(k, :) = fr_interp(fr_request, s_ps_mV(k));
end

save('s_pr_2d.mat', 's_pr_2d');

% fixed parameters
pm.neuron_model = 'HH-PT-GH';
pm.net     = 'net_2_2';
pm.scee_mV = 1.0;
%pm.pr    = 
%pm.ps_mV = 
pm.t    = 1e6;
pm.stv  = 0.5;
pm.extra_cmd = '';

scan_prps_worker_head;
