% compute firing freq

addpath([getenv('HOME') '/code/point-neuron-network-simulator/mfile/']);
addpath([getenv('HOME') '/matcode/prj_GC_clean/HH/scan_worker/']);
addpath(fileparts(mfilename('fullpath')));

% function to calculate in each loop
func_name = 'cal_cell_ISI';

pm = [];
pm.neuron_model = 'HH-GH';
pm.simu_method = 'simple';
pm.net     = 'net_1_0';
%pm.pr    = 
%pm.ps_mV = 
%pm.t    = 1e5;
pm.stv  = 1.0;
pm.extra_cmd = '--set-threshold 20';
in_const_data.pm = pm;

PSP = get_neu_psp(pm.neuron_model);

% generate input parameter set

%ps_mV = 0.05;  % called from external
s_prps = linspace(0.003,0.5, 100) / PSP.mV_ps;

s_pr = s_prps/ps_mV;
s_jobs = cell(size(s_pr));
for k=1:numel(s_pr)
  in.ps_mV = ps_mV;
  in.pr = s_pr(k);
  in.t = simu_time;
  s_jobs{k}=in;   % inputs are saved in a struct named 'in'
end

%ncpu = 4;  % number of cpu to use, comment it to use all CPUs

t0 = tic();
tocs = @(st) fprintf('%s: t = %6.3fs\n', st, toc());

% results will be saved here
data_file_name = sprintf('ISI_results/ISI_%s_ps=%.2gmV_prps=%.2g-%.2gmVkHz_t=%1.2e.mat', pm.neuron_model, ps_mV, s_prps(1), s_prps(end), simu_time);

prefix_tmpdata = 'ISI_results/';

parallel_distributor;

fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );
