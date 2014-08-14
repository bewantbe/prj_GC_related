
% function to calculate in each loop
func_name = 'cal_job_HH';

% generate input parameter set
simu_time = 1e5;
pr = 8;
s_prps = linspace(0.01,0.26, 50);
pr = 4;
s_prps = linspace(0.01,0.26, 10);
%pr = 2;
%s_prps = linspace(0.01,0.13, 50);  % 1min
%pr = 1;
%s_prps = linspace(0.01,0.065, 50);

s_ps = s_prps/pr;
s_jobs = cell(size(s_ps));
for k=1:numel(s_ps)
  in.pr = pr;
  in.ps = s_ps(k);
  in.simu_time = simu_time;
  s_jobs{k}=in;   % inputs are saved in a struct named 'in'
end

ncpu = 2;  % number of cpu to use, comment it to use all CPUs

t0 = tic();
tocs = @(st) fprintf('%s: t = %6.3fs\n', st, toc());

% results will be saved here
data_file_name = sprintf('ISI_results/ISI_HH_pr=%1.1f_prps=%.1e~%.1e_t=%1.2e.mat', pr, s_prps(1), s_prps(end), simu_time);

prefix_tmpdata = 'ISI_results/';

parallel_distributor;

fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );
