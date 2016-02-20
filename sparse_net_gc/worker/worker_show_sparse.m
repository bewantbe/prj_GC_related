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

% load results
s_data_file_name = {
%'scan_HH3_gcc49_westmere2_sparse=1.0e-02-2.0e-01_p=100_pr=1.0_ps=3.0e-02_scee=5.0e-02_t=1.0e+05'
'scan_HH3_gcc49_westmere2_sparse=1.0e-02-3.2e-01_p=100_pr=1.0_ps=3.0e-02_scee=5.0e-02_t=1.0e+06'
};

gen_network = @(np) eval(sprintf('%s(np);', np.generator));

for id_s_data = 1:length(s_data_file_name)

  data_file_name = ['scan_sparseness/' s_data_file_name{id_s_data} '.mat'];
  load(data_file_name);  % load 's_data', 's_jobs', 'in_const_data'

  pm        = in_const_data.pm;
  net_param = in_const_data.net_param;
  use_od    = in_const_data.use_od;
  len = round(pm.t / pm.stv);
  p = pm.nE+pm.nI;

  % variables in plot
  s_sparseness = zeros(size(s_jobs));
  s_sparseness_true = s_sparseness;
  s_correct_rate_best_guess = zeros(size(s_jobs));
  s_rate = zeros(size(s_jobs));
  s_rate_std = zeros(size(s_jobs));
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    ou = s_data{id_job};
    s_sparseness(id_job) = in.sparseness;
    
    % get the answer
    net_param.sparseness = in.sparseness;
    net_param.seed       = ou.net_seed;
    neu_network = gen_network(net_param);

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
    neu_network_best_guess = GC >= min_err_gc;
    adj_cmp_best_guess = neu_network_best_guess - neu_network;

    s_sparseness_true(id_job) = sum(plain_network)/(p*(p-1));

    s_rate(id_job) = mean(1000 ./ ou.ISI);
    s_rate_std(id_job) = std(1000 ./ ou.ISI);
  end

  [s_sparseness, id_sort] = sort(s_sparseness);
  s_correct_rate_best_guess = s_correct_rate_best_guess(id_sort);
  s_rate = s_rate(id_sort);
  s_rate_std = s_rate_std(id_sort);

  figure(2);
  plot(s_sparseness, 100*s_correct_rate_best_guess, 'o');
  xlabel('sparseness');
  ylabel('best edge correct reconstruction ratio (pairwise GC)');
  set(gca, 'xdir', 'reverse');
  ylim([50 100]);
  pic_output_color(sprintf('scan_sparse_correct_p=%d+%d_pr=%.1e_ps=%.1e_scee=%.1e_t=%.1e', pm.nE, pm.nI, pm.pr, pm.ps, pm.scee, pm.t));

  figure(3);
  errorbar(s_sparseness, s_rate, s_rate_std);
  xlabel('sparseness');
  ylabel('firing rate (distribution) (Hz)');
  set(gca, 'xdir', 'reverse');
  pic_output_color(sprintf('scan_sparse_ISI_p=%d+%d_pr=%.1e_ps=%.1e_scee=%.1e_t=%.1e', pm.nE, pm.nI, pm.pr, pm.ps, pm.scee, pm.t));

end

