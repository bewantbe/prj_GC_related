function cal_cell_GC_V_ST(input_fn, output_fn)
  load(input_fn);

  pm = in.const_data.pm;
  pm.pr    = in.pr;
  pm.ps_mV = in.ps_mV;

  addpath([getenv('HOME') '/code/point-neuron-network-simulator/mfile/']);
  addpath([getenv('HOME') '/matcode/GC_clean/GCcal/']);
  addpath([getenv('HOME') '/matcode/GC_clean/prj_neuron_gc/']);
  [X, ISI, ras, pm] = gen_neu(pm, 'rm');
  [p, len] = size(X);

  % Histogram of ISI
  hist_div = in.const_data.hist_div;
  ISI_dis = zeros(p, length(hist_div));
  for kk = 1:p
    tm = ras(ras(:,1)==kk, 2);
    tm = tm(2:end) - tm(1:end-1);
    ISI_dis(kk,:) = hist(tm, hist_div);
  end

  [oGC, oDe, R] = AnalyseSeriesFast(X, in.const_data.s_od);

  X = SpikeTrains(ras, p, len, pm.stv);
  [oGC_ST, oDe_ST, R_ST] = AnalyseSeriesFast(X, in.const_data.s_od);

  ou.ISI = ISI;       % save the results in a struct named "ou"
  ou.oGC = oGC;
  ou.oDe = oDe;
  ou.R = R;
  ou.oGC_ST = oGC_ST;
  ou.oDe_ST = oDe_ST;
  ou.R_ST = R_ST;
  save('-v7', output_fn, 'ou');
  s=datestr(now, 30);
  save('-v7', [output_fn '.finished'], 's');
