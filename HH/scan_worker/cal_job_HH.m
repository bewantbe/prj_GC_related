function cal_job_HH(input_fn, output_fn)
  load(input_fn);

  pm.neuron_model = in.neuron_model;
  pm.net  = 'net_2_2';
  pm.pr   = in.pr;
  pm.ps   = in.ps;
  pm.scee = in.scee;
  pm.t    = in.simu_time;
  pm.stv  = 0.5;
  pm.extra_cmd = '-q';

  addpath([getenv('HOME') '/matcode/prj_GC_clean/HH/']);
  addpath([getenv('HOME') '/matcode/GC_clean/GCcal/']);
  addpath([getenv('HOME') '/matcode/GC_clean/prj_neuron_gc/']);
  [X, ISI, ras, pm] = gen_HH(pm, 'rm');

  % Histogram of ISI
  p = pm.nE + pm.nI;
  hist_div = 0:1:500;          % ISI
  ISI_dis = zeros(p, length(hist_div));
  for kk = 1:p
    tm = ras(ras(:,1)==kk, 2);
    tm = tm(2:end) - tm(1:end-1);
    ISI_dis(kk,:) = hist(tm, hist_div);
  end

  s_od = 1:99;
  [oGC, oDe, R] = AnalyseSeriesFast(X, s_od);

  ou.ISI = ISI;       % save the results in a struct named "ou"
  ou.oGC = oGC;
  ou.oDe = oDe;
  ou.R = R;
  save('-v7', output_fn, 'ou');
