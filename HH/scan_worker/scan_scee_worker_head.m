% Fixed input parameters
% See scan_scee_worker_w_test.m

% function to calculate in each loop
func_name = 'cal_job_HH_VST';

pm.neuron_model = neuron_model;
pm.net  = 'net_2_2';
pm.pr   = pr;
pm.ps   = ps;
pm.t    = simu_time;
pm.stv  = 0.5;
pm.extra_cmd = '-q';

% Parameters beside scee
in_const_data.pm = pm;
in_const_data.s_od = 1:99;           % fitting order scan
in_const_data.hist_div = 0:1:500;    % ISI hist range

% generate input parameter set
s_jobs = cell(size(s_scee));
for k=1:numel(s_scee)
  in.scee = s_scee(k);
  s_jobs{k}=in;   % inputs are saved in a struct named 'in'
end

%ncpu = 2;  % number of cpu to use, comment it to use all CPUs

t0 = tic();
tocs = @(st) fprintf('%s: t = %6.3fs\n', st, toc());

st_extra = '_VST';

% results will be saved here
data_file_name = sprintf('scan_scee_results/scan_scee_%s_pr=%1.1f_ps=%.1e_scee=%.1e-%.1e_t=%1.1e%s.mat', neuron_model, pr, ps, in.scee(1), in.scee(end), simu_time, st_extra);
clear('st_extra');

prefix_tmpdata = 'scan_scee_results/';

parallel_distributor;

fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );
