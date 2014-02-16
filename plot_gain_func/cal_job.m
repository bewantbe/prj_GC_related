function cal_job(input_fn, output_fn)
  load(input_fn);

  netstr = 'net_1_0';
  pr = in.pr;
  ps = in.ps;
  scee = 0;
  simu_time = in.simu_time;
  stv = 1.0;
  extpara = '-q -dt 0.125';

  addpath(in.path);
  [~, ISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time, stv, extpara);
%  ISI = sum(ras(:,2)>200);  % ignore first 200ms data

  gendata_neu(netstr, scee, pr, ps, simu_time, stv, 'rm');

  ou.ISI = ISI;       % save the results in a struct named "ou"
  save('-v7', output_fn, 'ou');
