% show result of parallel_main
pic_common_include;
%set(0, 'defaultfigurevisible', 'off');
addpath([getenv('HOME') '/matcode/GC_clean/GCcal/']);

% load results
s_data_file_name = {
'scan_all_HH-PT-GH_ps=0.05-2.00mV_fr=1-80Hz_scee=1mV_t=1.0e+06_V_ST'
};

p = 2;
mode_ST = false;
if mode_ST
  st_ext = 'ST_';
else
  st_ext = '';
end

gc_scale = 1e-4;

for id_s_data = 1:length(s_data_file_name)

  data_file_name = ['scan_all_results/' s_data_file_name{id_s_data} '.mat'];
  load(data_file_name);  % load 's_data', 's_jobs', 'in_const_data'

  s_pr_2d = zeros(size(s_jobs));
  s_ps_mV = zeros(1, size(s_jobs, 1));
  s_fr = zeros(size(s_jobs));  % firing rate as x-axis
  s_BIC = zeros(size(s_jobs));
  s_freq = zeros([size(s_jobs), p]);
  s_gc = zeros([size(s_jobs), p]);
  s_gc_lu = zeros([size(s_jobs), 2*p]);
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    ou = s_data{id_job};
    
    [idi idj] = ind2sub(size(s_jobs), id_job);
    
    s_pr_2d(idi, idj) = in.pr;
    s_ps_mV(idi) = in.ps_mV;
    
    s_fr(id_job) = 1000 / ou.ISI(1);
    
    len = in_const_data.pm.t / in_const_data.pm.stv;
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
%    use_od = max([20, bic_od]);  % TODO: fix 20?
    use_od = bic_od;
    if use_od < 10
      [a b] = chooseROrderFull(R, len, 'BIC');
      use_od = max([a b]);
    end
    s_BIC(id_job) = use_od;
    
    s_gc(idi, idj, :) = [oGC(2, 1, use_od), oGC(1, 2, use_od)] - use_od/len;
    [gc_lower, gc_upper] = gc_prob_intv(oGC(:, :, use_od), use_od, len);
    % order: gc(x->y) lower, gc(y->x) lower, gc(x->y) upper, gc(y->x) upper
    s_gc_lu(idi, idj, :) = [gc_lower([2 3]), gc_upper([2 3])];
    s_freq(idi, idj, :) = 1000 ./ ou.ISI;
  end

  cm = rainbow(length(s_ps_mV));
  figure(3);
  cla
  clf
  hold on
  for k = 1 : length(s_ps_mV)
    plot(s_fr(k, :), s_gc(k,:,1)/gc_scale, 'color', cm(k,:));
  end
  xlim([0, s_fr(end)]);
  xlabel('Firing Rate (Hz)');
  ylabel(sprintf('GC (%g)', gc_scale));
  pic_output_color(['GC1_1d_' st_ext s_data_file_name{id_s_data}]);

  figure(4);
  cla
  clf
  hold on
  for k = 1 : length(s_ps_mV)
    plot(s_fr(k, :), s_gc(k,:,2)/gc_scale, 'color', cm(k,:));
  end
  xlim([0, s_fr(end)]);
  xlabel('Firing Rate (Hz)');
  ylabel(sprintf('GC (%g)', gc_scale));
  pic_output_color(['GC0_1d_' st_ext s_data_file_name{id_s_data}]);

  figure(5);
  cla
  clf
  hold on
  for k = 1 : length(s_ps_mV)
    plot(s_fr(k, :), s_BIC(k,:), 'color', cm(k,:));
  end
  xlim([0, s_fr(end)]);
  ylim([0, ylim()(2)])
  xlabel('Firing Rate (Hz)');
  ylabel('BIC order');
  pic_output_color(['BICod_1d_' st_ext s_data_file_name{id_s_data}]);

  figure(15);
  pcolor(s_fr, s_ps_mV'*ones(size(s_ps_mV)), s_BIC);
  shading flat
  colorbar();
  xlabel('Firing Rate (Hz)');
  ylabel('f (mV)');
  pic_output_color(['BICod_2d_' st_ext s_data_file_name{id_s_data}]);

  figure(13);
  pcolor(s_fr, s_ps_mV'*ones(size(s_ps_mV)), s_gc(:,:,1)/gc_scale);
  shading flat
  colorbar();
  xlabel('Firing Rate (Hz)');
  ylabel('f (mV)');
  pic_output_color(['GC1_2d_' st_ext s_data_file_name{id_s_data}]);

%  figure(4);
%  plot(s_freq(:,:,1)');
end

