% 2D interpolation for firing rate.
% fr_request = 20;
% ps_request = 1.0; % mV
% pr_at_ps_fr_request = fr_interp(fr_request, ps_request)

function pr_at_ps_fr_request = fr_interp(fr_request, ps_request)

PSP = get_neu_psp('HH-GH');
ps_request = ps_request * PSP.mV_ps;

path_prefix = '/home/xyy/matcode/prj_GC_clean/plot_gain_func/ISI_results/';

s_data_file_name = {
'ISI_HH_ps=0.065_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.032_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.016_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.008_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.004_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.002_prps=3.0e-03~5.0e-01_t=4.00e+05'
};

pr_at_fr_request = zeros(size(s_data_file_name));
s_ps = zeros(size(s_data_file_name));

for id_s_data = 1:length(s_data_file_name)
  data_file_name = [path_prefix, s_data_file_name{id_s_data}, '.mat'];
  load(data_file_name);
  s_prps = zeros(size(s_jobs));
  s_freq = zeros(size(s_jobs));
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    s_prps(id_job) = in.pr * in.ps;
    ou = s_data{id_job};
    s_freq(id_job) = 1000/ou.ISI;
  end
  s_ps(id_s_data) = in.ps;
  pp = pchip(s_prps, s_freq);
  prps_at_fr_request(id_s_data) = fzero(
    @(x) ppval(pp, x) - fr_request, s_prps([1 end]));
end

pr_at_ps_fr_request = pchip(s_ps, prps_at_fr_request, ps_request) / ps_request;

