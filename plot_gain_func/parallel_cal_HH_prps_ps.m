
% function to calculate in each loop
func_name = 'cal_job_HH';

% generate input parameter set
simu_time = 4e5;
%ps = 0.002;
s_prps = linspace(0.003,0.5, 100);
%ps = 0.004;
%s_prps = linspace(0.003,0.5, 100);
%ps = 0.008;
%s_prps = linspace(0.003,0.5, 100);
%ps = 0.016;
%s_prps = linspace(0.003,0.5, 100);
%ps = 0.032;
%s_prps = linspace(0.003,0.5, 100);
%ps = 0.065;
%s_prps = linspace(0.003,0.5, 100);

s_pr = s_prps/ps;
s_jobs = cell(size(s_pr));
for k=1:numel(s_pr)
  in.ps = ps;
  in.pr = s_pr(k);
  in.simu_time = simu_time;
  s_jobs{k}=in;   % inputs are saved in a struct named 'in'
end

ncpu = 4;  % number of cpu to use, comment it to use all CPUs

t0 = tic();
tocs = @(st) fprintf('%s: t = %6.3fs\n', st, toc());

% results will be saved here
data_file_name = sprintf('ISI_results/ISI_HH_ps=%g_prps=%.1e~%.1e_t=%1.2e.mat', ps, s_prps(1), s_prps(end), simu_time);

prefix_tmpdata = 'ISI_results/';

parallel_distributor;

fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );
