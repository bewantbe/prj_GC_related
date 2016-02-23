function worker_cell_GC_HH_VST(input_fn, output_fn, need_postprocess)
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

  data_dir_prefix = ['.', filesep, 'data', filesep, in.const_data.identity_str, '_'];

  if ~exist('need_postprocess', 'var')
    gen_HH(pm, 'ext_T', data_dir_prefix);
    ou.need_postprocess = ['finish data gen '  datestr(now, 30)];
    save('-v7', output_fn, 'ou');
    s = ou.need_postprocess;
    save('-v7', [output_fn '.finished'], 's');
    return;
  end
  if isfield(in, 'no_postprocess')
    ou.need_postprocess = ['data postprocess ignored. '  datestr(now, 30)];
    save('-v7', output_fn, 'ou');
    s = ou.need_postprocess;
    save('-v7', [output_fn '.finished'], 's');
    return;
  end

  [X_file, ISI, ras, pm] = gen_HH(pm, 'nameX,ext_T', data_dir_prefix);
  p = net_param.p;
  len = floor(pm.t/pm.stv);
  x_skip = floor(pm.ext_T/pm.stv);
  R = getcovpdFile(X_file, p, in.const_data.use_od, x_skip);
  gen_HH(pm, 'rm', data_dir_prefix);

  ou.net_seed = net_param.seed;
  ou.ISI = ISI;

  [ou.GC, ou.De] = RGrangerTLevinson(R);
  ou.pairGC = pairRGrangerT(R);
  clear('R');

%  X = SpikeTrains(ras, p, len, pm.stv);
%  clear('ras');

%  R = getcovpd(X, in.const_data.use_od);
%  clear('X');
%  [ou.GC_ST, ou.De_ST] = RGrangerTLevinson(R);
%  ou.pairGC_ST = pairRGrangerT(R);

  save('-v7', output_fn, 'ou');
  s=datestr(now, 30);
  save('-v7', [output_fn '.finished'], 's');
