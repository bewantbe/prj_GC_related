%
addpath([getenv('HOME') '/matcode/prj_GC_clean/plot_gain_func/']);

% function to calculate in each loop
func_name = 'cal_job_HH';

% input parameters
neuron_model = 'HH3_gcc49_westmere';
pr = 1.6;
ps = 0.04;
s_scee = 0.05*linspace(0, 1, 10);
simu_time = 1e6;

% generate input parameter set
s_jobs = cell(size(s_scee));
for k=1:numel(s_scee)
  in.neuron_model = neuron_model;
  in.pr = pr;
  in.ps = ps;
  in.scee = s_scee(k);
  in.simu_time = simu_time;
  s_jobs{k}=in;   % inputs are saved in a struct named 'in'
end

%ncpu = 2;  % number of cpu to use, comment it to use all CPUs

t0 = tic();
tocs = @(st) fprintf('%s: t = %6.3fs\n', st, toc());

% results will be saved here
data_file_name = sprintf('scan_scee_results/scan_scee_%s_pr=%1.1f_ps=%.1e_scee=%.1e-%.1e_t=%1.1e.mat', neuron_model, pr, ps, in.scee(1), in.scee(end), simu_time);

prefix_tmpdata = 'scan_scee_results/';

parallel_distributor;

fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );
