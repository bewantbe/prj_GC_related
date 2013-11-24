%

fn_prefix = 'pic_data/';

% use volt
s_fn_save = {
'IF_net_2_2_sc=0.0100_ps=0.0050_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
'IF_net_2_2_sc=0.0100_ps=0.0050_stv=0.50_t=1.00e+07_scan_prps.mat',
'IF_net_2_2_sc=0.0100_ps=0.0100_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
'IF_net_2_2_sc=0.0100_ps=0.0100_stv=0.50_t=1.00e+07_scan_prps.mat',
'IF_net_2_2_sc=0.0100_ps=0.0200_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
'IF_net_2_2_sc=0.0100_ps=0.0200_stv=0.50_t=1.00e+07_scan_prps.mat'};

% use spike train
s_fn_save = {
'IF_ST_net_2_2_sc=0.0100_ps=0.0050_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
'IF_ST_net_2_2_sc=0.0100_ps=0.0050_stv=0.50_t=1.00e+07_scan_prps.mat',
'IF_ST_net_2_2_sc=0.0100_ps=0.0100_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
'IF_ST_net_2_2_sc=0.0100_ps=0.0100_stv=0.50_t=1.00e+07_scan_prps.mat',
'IF_ST_net_2_2_sc=0.0100_ps=0.0200_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
'IF_ST_net_2_2_sc=0.0100_ps=0.0200_stv=0.50_t=1.00e+07_scan_prps.mat'};

figure(1);
clf; cla;
hold on
s_color = {'b','g','r','c','y','k','m'};

for id_save = 1:length(s_fn_save)
  fn_save = s_fn_save{id_save};
  load([fn_prefix, fn_save]);

  s_freq = 1000./mean(s_ISIs);

  IFtype = myif(mode_eif, 'EIF', 'IF');
  IFtype = [IFtype, myif(mode_st, ' (spike train)', ' (volt)')];
  fprintf('net="%s", scee=%.3f, ps=%.3f, freq=%.2f~%.2f Hz, %s.\n',...
          netstr, scee, ps, min(s_freq), max(s_freq), IFtype);

  s_len_min(gc_prob_nonzero(s_flat_gc(1,:),s_bic_ods,len)<0.9) = Inf;   % exclude meaningless points

  figure(1);
  hd=plot(s_freq, s_len_min*stv/60e3);
  legend(hd, sprintf('ps=%.3f',ps));
  set(hd, 'color', s_color{mod(id_save-1, length(s_color))+1});
end

figure(1);
hold off
xlabel('freq/Hz');
ylabel('min length / min');

  %{
  figure(2);
  plot(s_freq, s_flat_gc);
  xlabel('freq/Hz');
  ylabel('GC');

  figure(14);
  plot(s_freq, [s_flat_ugc; s_flat_lgc]);
  xlabel('freq/Hz');
  ylabel('GC confidence interval');

  figure(11);
  plot(s_freq, s_prps);
  xlabel('freq/Hz');
  ylabel('prps');

  figure(12);
  plot(s_freq, s_ISIs);
  xlabel('freq/Hz');
  ylabel('ave ISI of each neurons / ms');

  figure(13);
  plot(s_freq, s_bic_ods);
  xlabel('freq/Hz');
  ylabel('BIC order');
  %}
