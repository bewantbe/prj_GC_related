% 2D interpolation for firing rate.
% fr_request = 20;
% ps_request = 1.0; % mV
% pr_at_ps_fr_request = fr_interp(fr_request, ps_request)

function pr_at_ps_fr_request = fr_interp(fr_request, ps_request)

%addpath('~/code/point-neuron-network-simulator/mfile');
%PSP = get_neu_psp('HH-GH');
%ps_request = ps_request * PSP.mV_ps;

%path_prefix = '~/matcode/prj_GC_clean/plot_gain_func/ISI_results/';
%s_data_file_name = {
%'ISI_HH_ps=0.065_prps=3.0e-03~5.0e-01_t=4.00e+05'
%'ISI_HH_ps=0.032_prps=3.0e-03~5.0e-01_t=4.00e+05'
%'ISI_HH_ps=0.016_prps=3.0e-03~5.0e-01_t=4.00e+05'
%'ISI_HH_ps=0.008_prps=3.0e-03~5.0e-01_t=4.00e+05'
%'ISI_HH_ps=0.004_prps=3.0e-03~5.0e-01_t=4.00e+05'
%'ISI_HH_ps=0.002_prps=3.0e-03~5.0e-01_t=4.00e+05'
%};

path_prefix = '~/matcode/prj_GC_clean/HH_reboot/ISI_results/';
s_data_file_name = {
'ISI_HH-GH_ps=2mV_prps=0.089-15mVkHz_t=1.00e+07'
'ISI_HH-GH_ps=1mV_prps=0.089-15mVkHz_t=1.00e+07'
'ISI_HH-GH_ps=0.5mV_prps=0.089-15mVkHz_t=1.00e+07'
'ISI_HH-GH_ps=0.2mV_prps=0.089-15mVkHz_t=1.00e+07'
'ISI_HH-GH_ps=0.1mV_prps=0.089-15mVkHz_t=1.00e+07'
'ISI_HH-GH_ps=0.05mV_prps=0.089-15mVkHz_t=1.00e+07'
};

prps_at_fr_request = zeros(numel(fr_request), numel(s_data_file_name));
s_ps = zeros(size(s_data_file_name));

for id_s_data = 1:numel(s_data_file_name)
  data_file_name = [path_prefix, s_data_file_name{id_s_data}, '.mat'];
  load(data_file_name);
  s_prps_mV = zeros(size(s_jobs));
  s_freq    = zeros(size(s_jobs));
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    s_prps_mV(id_job) = in.pr * in.ps_mV;
    ou = s_data{id_job};
    s_freq(id_job) = 1000/ou.ISI;
  end
  s_ps_mV(id_s_data) = in.ps_mV;
  pp = pchip(s_prps_mV, s_freq);
  
  for k = 1 : numel(fr_request)
    prps_at_fr_request(k, id_s_data) = fzero(
      @(x) ppval(pp, x) - fr_request(k), s_prps_mV([1 end]));
  end
end

pr_at_ps_fr_request = zeros(size(fr_request));
for k = 1 : numel(fr_request)
  pr_at_ps_fr_request(k) = pchip(s_ps_mV, prps_at_fr_request(k, :), ps_request) / ps_request;
end

