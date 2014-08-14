function cal_job(input_fn, output_fn)
  load(input_fn);

  pm.net  = 'net_1_0';
  pm.pr   = in.pr;
  pm.ps   = in.ps;
  pm.scee = 0;
  pm.t    = in.simu_time;
  pm.stv  = 1.0;
  pm.extra_cmd = '-q';

  [~, ISI] = gen_HH(pm, 'rm');

  ou.ISI = ISI;       % save the results in a struct named "ou"
  save('-v7', output_fn, 'ou');
