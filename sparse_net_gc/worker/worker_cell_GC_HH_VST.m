function worker_cell_GC_HH_VST(input_fn, output_fn)
  addpath([getenv('HOME') '/matcode/GC_clean/GCcal/']);
  addpath([getenv('HOME') '/matcode/GC_clean/prj_neuron_gc/']);
  addpath([getenv('HOME') '/matcode/prj_GC_clean/HH/']);
  addpath([getenv('HOME') '/matcode/prj_GC_clean/sparse_net_gc/']);
  load(input_fn);

  pm = in.const_data.pm;
  net_param = in.const_data.net_param;

  net_param.sparseness = in.sparseness;
  net_param.seed       = in.net_seed;
  gen_network = @(np) eval(sprintf('%s(np);', np.generator));
  pm.net  = gen_network(net_param);
  pm.net_param = net_param;

  [X, ISI, ras, pm] = gen_HH(pm, 'rm');
  [p, len] = size(X);
  X = WhiteningFilter(X, 4);

  ou.net_seed = net_param.seed;
  ou.ISI = ISI;

  R = getcovpd(X, in.const_data.use_od);
  clear('X');
  [ou.GC, ou.De] = RGrangerTLevinson(R);
  ou.pairGC = pairRGrangerT(R);
  clear('R');

  X = SpikeTrains(ras, p, len, pm.stv);
  clear('ras');

  R = getcovpd(X, in.const_data.use_od);
  clear('X');
  [ou.GC_ST, ou.De_ST] = RGrangerTLevinson(R);
  ou.pairGC_ST = pairRGrangerT(R);

  save('-v7', output_fn, 'ou');
