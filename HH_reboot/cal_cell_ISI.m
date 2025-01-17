function cal_cell_ISI(input_fn, output_fn)
  load(input_fn);

  pm = in.const_data.pm;
  pm.pr    = in.pr;
  pm.ps_mV = in.ps_mV;
  pm.t     = in.t;

  addpath([getenv('HOME') '/code/point-neuron-network-simulator/mfile/']);
  [~, ISI] = gen_neu(pm, 'rm');

  ou.ISI = ISI;       % save the results in a struct named "ou"
  save('-v7', output_fn, 'ou');
  s=datestr(now, 30);
  save('-v7', [output_fn '.finished'], 's');
