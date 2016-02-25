% show result of parallel_main
    fontsize = 19;
    linewidth = 1;
    pic_prefix = 'pic_tmp/';
    pic_output       = @(st)print('-deps',  [pic_prefix, st, '.eps']);
    pic_output_color = @(st)print('-depsc2',[pic_prefix, st, '.eps']);
%    set(0, 'defaultfigurevisible', 'off');
    set(0, 'defaultlinelinewidth', linewidth);
    set(0, 'defaultaxesfontsize', fontsize);

%set(0, 'defaultfigurevisible', 'off');
addpath([getenv('HOME') '/matcode/GC_clean/GCcal/']);

gen_network = @(np) eval(sprintf('%s(np);', np.generator));

for id_s_data = 1:length(s_data_file_name)

  if iscell(s_data_file_name{id_s_data})
    % combine job group (scan different area (other parameters are exactly the same))
    cell_data_file = s_data_file_name{id_s_data};
    c_data = {};
    c_jobs = {};
    for id_c_data = 1:numel(cell_data_file)
      data_file_name = ['scan_sparseness/' cell_data_file{id_c_data} '.mat'];
      load(data_file_name);  % load 's_data', 's_jobs', 'in_const_data'
      c_data = {c_data{:}, s_data{:}};
      c_jobs = {c_jobs{:}, s_jobs{:}};
    end
    s_data = c_data;
    s_jobs = c_jobs;
  else
    data_file_name = ['scan_sparseness/' s_data_file_name{id_s_data} '.mat'];
    load(data_file_name);  % load 's_data', 's_jobs', 'in_const_data'
  end
  
  pm        = in_const_data.pm;
  net_param = in_const_data.net_param;
  use_od    = in_const_data.use_od;
  len = round(pm.t / pm.stv);
  p = pm.nE+pm.nI;

  % variables in plot
  s_sparseness = zeros(size(s_jobs));
  s_sparseness_true = s_sparseness;
  s_correct_rate_best_guess = zeros(size(s_jobs));
  s_correct_rate_pval = zeros(size(s_jobs));
  s_rate = zeros(size(s_jobs));
  s_rate_std = zeros(size(s_jobs));
  s_indirect2connect = zeros(size(s_jobs));
  s_supposeWrongPairGC = zeros(size(s_jobs));
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    ou = s_data{id_job};
    s_sparseness(id_job) = in.sparseness;
    
    % get the answer
    net_param.sparseness = in.sparseness;
    net_param.seed       = ou.net_seed;
    neu_network = 1.0*gen_network(net_param);

    GC = ou.pairGC;

    % flatten the GC and connection matrix
    plain_gc = GC(eye(p)==0);
    plain_network = neu_network(eye(p)==0);

    % auto determine cutline
    [sorted_gc, sorted_gc_id] = sort(plain_gc);
    sorted_gc_zeroone = plain_network(sorted_gc_id);
    tmp_0 = cumsum(sorted_gc_zeroone==0);
    tmp_0 = tmp_0(end) - tmp_0;
    tmp_1 = cumsum(sorted_gc_zeroone>0);
    [~, min_err_id] = min([tmp_0; 0] + [0; tmp_1]);
    min_err_gc = sorted_gc(min_err_id);
    p_val_min_err = 1-chi2cdf(min_err_gc*len, use_od);
    neu_network_best_guess = GC >= min_err_gc;
    adj_cmp_best_guess = neu_network_best_guess - neu_network;

    s_correct_rate_best_guess(id_job) = sum(0==adj_cmp_best_guess(eye(p)==0))/(p*(p-1));

    % cutline according to p-value
    p_val = min(0.01, 1 / p);
    gc_zero_line = chi2inv(1-p_val, use_od)/len;
    neu_network_pval = GC >= gc_zero_line;
    adj_cmp_pval = neu_network_pval - neu_network;

    s_correct_rate_pval(id_job) = sum(0==adj_cmp_pval(eye(p)==0))/(p*(p-1));

    s_sparseness_true(id_job) = sum(plain_network)/(p*(p-1));

    s_rate(id_job) = mean(1000 ./ ou.ISI);
    s_rate_std(id_job) = std(1000 ./ ou.ISI);

    net_2indirect = neu_network*neu_network;  % indirect connection
    net_2indirect(eye(p)==1) = 0;             % remove loop back interactions
    net_2common = neu_network*neu_network';   % common input
    net_2common(eye(p)==1) = 0;               % remove self common input
    s_indirect2connect(id_job) = mean(net_2indirect(eye(p)==0)+net_2common(eye(p)==0));
  end

  fprintf('p = %d (%dE + %dI)\n', p, pm.nE, pm.nI);
  fprintf('  using p-val = %.2g\n', p_val);

  [s_sparseness, id_sort] = sort(s_sparseness);
  s_correct_rate_best_guess = s_correct_rate_best_guess(id_sort);
  s_correct_rate_pval = s_correct_rate_pval(id_sort);
  s_rate = s_rate(id_sort);
  s_rate_std = s_rate_std(id_sort);
  s_indirect2connect = s_indirect2connect(id_sort);
  
  param_str = sprintf('p=%d+%d_pr=%.1e_ps=%.1e_sc=%.1g,%.1g,%.1g,%.1g_t=%.1e', pm.nE, pm.nI, pm.pr, pm.ps, pm.scee, pm.scie, pm.scei, pm.scii, pm.t);
  if isfield(in_const_data, 'identity_str')
    if isempty(strfind(in_const_data.identity_str, '['))
      param_str = [param_str '_j' in_const_data.identity_str];
    else
      tmp_p = strfind(in_const_data.identity_str, '[')-1;
      param_str = [param_str '_j' in_const_data.identity_str(1:tmp_p)];
    end
  end

  figure(1);
  plot(s_sparseness, 100*s_correct_rate_pval, 'o');
  xlabel('sparseness');
  ylabel('p-val correct reconstruction ratio (pairwise GC)');
  xlim([0, max(s_sparseness)]);
%  ylim([50 100]);
  set(gca, 'xdir', 'reverse');
  pic_output_color(['scan_sparse_correct_pval_' param_str]);

  figure(2);
  plot(s_sparseness, 100*s_correct_rate_best_guess, 'o');
  xlabel('sparseness');
  ylabel('best edge correct reconstruction ratio (pairwise GC)');
  xlim([0, max(s_sparseness)]);
  ylim([50 100]);
  set(gca, 'xdir', 'reverse');
  pic_output_color(['scan_sparse_correct_best_' param_str]);

  figure(3);
  errorbar(s_sparseness, s_rate, s_rate_std);
  xlim([0, max(s_sparseness)]);
  xlabel('sparseness');
  ylabel('firing rate (distribution) (Hz)');
  set(gca, 'xdir', 'reverse');
  pic_output_color(['scan_sparse_ISI_' param_str]);

  figure(4);
%  [axs, h1, h2] = plotyy(s_sparseness, 100*s_correct_rate_pval, s_sparseness, s_indirect2connect);
  [axs, h1, h2] = plotyy(s_sparseness, s_indirect2connect, s_sparseness, 100*s_correct_rate_pval);
  xlim(axs(2), [0, max(s_sparseness)]);
  xlim(axs(1), [0, max(s_sparseness)]);
  ylim(axs(1), [0, 20]);  % hand tune ....
  xlabel('sparseness');
  ylabel(axs(1), 'p-val correct reconstruction ratio (pairwise GC)');
  ylabel(axs(2), 'mean # of indirect and common inputs');
  set(axs(1), 'xdir', 'reverse');
  set(axs(2), 'xdir', 'reverse');
  set(h1, 'Marker', 'o');  % , 'LineStyle', 'None'
  set(h2, 'Marker', 'x');
  pic_output_color(['scan_sparse_yy_indir_comm_correct_pval_' param_str]);

  figure(5);
  plot(s_sparseness, s_indirect2connect, 'o');
  xlabel('sparseness');
  ylabel('mean # of indirect and common inputs');
  xlim([0, max(s_sparseness)]);
  set(gca, 'xdir', 'reverse');
  pic_output_color(['scan_sparse_indir_comm_' param_str]);
  
  figure(6);
  plot(s_indirect2connect, 100*s_correct_rate_pval, 'o');
  xlim([0 2*s_sparseness(end)^2*p]);
  xlabel('mean # of indirect and common inputs');
  ylabel('p-val correct reconstruction ratio (pairwise GC)');
  pic_output_color(['scan_sparse_xy_indir_comm_correct_pval_' param_str]);

end

