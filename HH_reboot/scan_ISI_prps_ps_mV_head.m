% compute firing freq

addpath([getenv('HOME') '/code/point-neuron-network-simulator/mfile/']);
addpath([getenv('HOME') '/matcode/prj_GC_clean/HH/scan_worker/']);
addpath(fileparts(mfilename('fullpath')));

% function to calculate in each loop
func_name = 'cal_cell_ISI';

pm = [];
pm.neuron_model = neuron_model;
pm.simu_method = 'simple';
pm.net     = 'net_1_0';
%pm.pr    = 
%pm.ps_mV = 
%pm.t    = 1e5;
pm.stv  = 100.0;
pm.extra_cmd = extra_cmd;
in_const_data.pm = pm;

% generate input parameter set
s_pr = s_prps_mV / ps_mV;
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
data_file_name = sprintf('%sISI_%s_ps=%.2gmV_prps=%.2g-%.2gmVkHz_t=%1.2e%s.mat',...
  prefix_tmpdata, pm.neuron_model, ps_mV, s_prps_mV(1), s_prps_mV(end), simu_time, name_suffix);

parallel_distributor;

fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );
