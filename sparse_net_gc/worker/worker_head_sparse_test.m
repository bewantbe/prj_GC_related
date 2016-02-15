% Scan sparseness of big network.

%input:
%simu_time = 1e5;
%p = 100;
%s_sparseness = linspace(1, round(sqrt(p*4)), 30)/p;
%Note:
% p * prob * prob = const.; prob = o/p;
% o = sqrt(const. * p);

net_param = [];
net_param.generator  = 'gen_sparse_mt19937';
net_param.p          = p;
%net_param.sparseness = 3/net_param.p;
%net_param.seed       = 4563;
net_param.software   = 'MT19937';

pm = [];
pm.neuron_model = 'HH3_gcc49_westmere2';
pm.net_param = net_param;
%pm.net  = gen_network(net_param);
pm.nI   = round(0.2*net_param.p);
pm.nE   = net_param.p - pm.nI;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.10;
pm.scii = 0.10;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = simu_time; % 1e5;
pm.stv  = 0.5;
pm.extra_cmd = '-q';

use_od = 40;

in_const_data.pm = pm;
in_const_data.net_param = net_param;
in_const_data.use_od = use_od;

s_jobs = cell(size(s_sparseness));
for k=1:numel(s_jobs)
  in.sparseness = s_sparseness(k);
  s_jobs{k}=in;   % inputs are saved in a struct named 'in'
end

% function to calculate in each loop
func_name = 'worker_cell_GC_HH_VST';

% results will be saved here
data_file_name = sprintf('scan_sparseness/scan_%s_sparse=%.1e-%.1e_p=%d_pr=%1.1f_ps=%.1e_scee=%.1e_t=%1.1e.mat', pm.neuron_model, s_sparseness(1), s_sparseness(end), net_param.p, pm.pr, pm.ps, pm.scee(1), pm.t);

prefix_tmpdata = 'data/';
addpath([getenv('HOME') '/matcode/prj_GC_clean/HH/scan_worker']);
t0 = tic();
parallel_distributor;
fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );

