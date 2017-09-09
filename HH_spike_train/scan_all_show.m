% show result of parallel_main
pic_common_include;
%set(0, 'defaultfigurevisible', 'off');
addpath([getenv('HOME') '/matcode/GC_clean/GCcal/']);

% load results
s_data_file_name = {
'scan_all_HH-GH_ps=0.5mV_prps=0.7-4mVHz_scee=1mV_t=1.0e+05_V_ST'
};

p = 2;
stv = 0.5;    % see also cal_job_HH.m for this value
mode_ST = false;
if mode_ST
  st_ext = 'ST_';
else
  st_ext = '';
end

for id_s_data = 1:length(s_data_file_name)

  data_file_name = ['scan_all_results/' s_data_file_name{id_s_data} '.mat'];
  load(data_file_name);  % load 's_data', 's_jobs', 'in_const_data'

  s_fr = zeros(size(s_jobs));  % firing rate as x-axis

  s_freq = zeros(numel(s_jobs), p);
  s_gc = zeros(numel(s_jobs), p);
  s_gc_lu = zeros(numel(s_jobs), 2*p);
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    ou = s_data{id_job};
    
    s_fr(id_job) = 1000 / ou.ISI(1);
    
    len = in_const_data.pm.t/stv;
    if mode_ST
      oGC = ou.oGC_ST;
      oDe = ou.oDe_ST;
      R = ou.R_ST;
    else
      oGC = ou.oGC;
      oDe = ou.oDe;
      R = ou.R;
    end
    s_od = in_const_data.s_od;
    [aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
    use_od = bic_od;
    s_gc(id_job, :) = [oGC(2, 1, use_od), oGC(1, 2, use_od)] - use_od/len;
    [gc_lower, gc_upper] = gc_prob_intv(oGC(:, :, use_od), use_od, len);
    % order: gc(x->y) lower, gc(y->x) lower, gc(x->y) upper, gc(y->x) upper
    s_gc_lu(id_job, :) = [gc_lower([2 3]), gc_upper([2 3])];
    s_freq(id_job, :) = 1000 ./ ou.ISI;
  end

  figure(2);
  plot(s_fr, s_gc*1e4, '-o', 'markersize', 2);
  xlim([0, s_fr(end)]);
%  ylim([0 s_gc(end, 1)*1e4*1.1]);
  xlabel('Firing Rate (Hz)');
  ylabel('GC (10^4)');
  pic_output_color(['plot_' st_ext s_data_file_name{id_s_data}]);

%  For scee
%  figure(2);
%  plot(s_scee.^2, s_gc*1e4, '-o', 'markersize', 2);
%  xlim([0, s_scee(end).^2]);
%%  ylim([0 s_gc(end, 1)*1e4*1.1]);
%  xlabel('S^2');
%  ylabel('GC (10^4)');
%  pic_output_color(['plot_' st_ext s_data_file_name{id_s_data}]);

%  figure(3);
%  errorbar(s_scee.^2, s_gc(:,1)*1e4,...
%    (s_gc(:,1)-s_gc_lu(:,1))*1e4, (s_gc_lu(:,3)-s_gc(:,1))*1e4);
%  xlim([0, s_scee(end).^2]);
%  yl=ylim();
%  ylim([0 yl(2)]);
%  xlabel('S^2');
%  ylabel('GC (10^4)');
%  pic_output_color(['ploterr_' st_ext s_data_file_name{id_s_data}]);

  figure(4);
  plot(s_freq);
end

