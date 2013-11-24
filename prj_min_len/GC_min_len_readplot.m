%

fn_prefix = 'pic_tmp/';

s_fn_save = {
'IF_net_2_2_sc=0.0100_ps=0.0100_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
'IF_net_2_2_sc=0.0100_ps=0.0200_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
};

s_fn_save = {
'IF_ST_net_2_2_sc=0.0100_ps=0.0100_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
'IF_ST_net_2_2_sc=0.0100_ps=0.0200_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
};

%s_fn_save = {
%'IF_ST_net_2_2_sc=0.0200_ps=0.0100_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat',
%'IF_ST_net_2_2_sc=0.0200_ps=0.0200_stv=0.50_t=1.00e+07_bigISI_scan_prps.mat'
% };

%c_len_min = zeros(length(s_prps), length(s_fn_save));
%c_freq    = zeros(length(s_prps), length(s_fn_save));
%c_legend_label = cell(length(s_fn_save),1);

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

  %c_freq(:, id_save)   = s_freq;
  %c_len_min(:, id_save) = s_len_min*stv/60e3;
  %c_legend_label{id_save} = sprintf('ps=%.3f',ps);

  figure(1);
  hd=plot(s_freq, s_len_min*stv/60e3);
  legend(hd, sprintf('ps=%.3f',ps));
  set(hd, 'color', s_color{mod(id_save-1, length(s_color))+1});
end

figure(1);
xlabel('freq/Hz');
ylabel('min length / min');

%figure(1);
%plot(c_freq, c_len_min);
%xlabel('freq/Hz');
%ylabel('min length / min');
%legend(c_legend_label);

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
  plot(s_freq, s_bic_od);
  xlabel('freq/Hz');
  ylabel('BIC order');
  %}
