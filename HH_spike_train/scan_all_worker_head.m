% Fixed input parameters
% See scan_scee_worker_w_test.m

% function to calculate in each loop
func_name = 'cal_cell_GC_V_ST';

% Common parameters
in_const_data.pm = pm;
in_const_data.s_od = 1:99;           % fitting order scan
in_const_data.hist_div = 0:1:500;    % ISI hist range

% generate input parameter set
s_jobs = cell(size(s_pr_ps));
for k=1:numel(s_pr_ps)
  in.pr    = s_pr_ps(k) / ps_mV;
  in.ps_mV = ps_mV;
  s_jobs{k}=in;   % inputs are saved in a struct named 'in'
end

%ncpu = 2;  % number of cpu to use, comment it to use all CPUs

t0 = tic();
tocs = @(st) fprintf('%s: t = %6.3fs\n', st, toc());

st_extra = '_V_ST';

% results will be saved here
data_file_name = sprintf('scan_all_results/scan_all_%s_ps=%1.1fmV_prps=%.2g-%.2gmVHz_scee=%.2gmV_t=%1.1e%s.mat',...
  pm.neuron_model, ps_mV, s_pr_ps(1), s_pr_ps(end), pm.scee_mV, pm.t, st_extra);
clear('st_extra');

prefix_tmpdata = 'scan_all_results/';

parallel_distributor;

fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );
