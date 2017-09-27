function cal_cell_ISI(input_fn, output_fn)
  load(input_fn);

  pm = in.const_data.pm;
  pm.pr    = in.pr;
  pm.ps_mV = in.ps_mV;
  pm.t     = in.t;
  if isfield(pm, 'extra_cmd')
    pm.extra_cmd = [pm.extra_cmd '-v --verbose-echo'];
  else
    pm.extra_cmd = '-v --verbose-echo';
  end

  addpath([getenv('HOME') '/code/point-neuron-network-simulator/mfile/']);
  [V, ISI, RAS, pm] = gen_neu(pm, 'rm');

  if length(V) > 200  
    ou.V = V(:, [1:100 end-100:end]);
  else
    ou.V = V;
  end

  if length(RAS) > 200  
    ou.RAS = RAS([1:100 end-100:end], :);
  else
    ou.RAS = RAS;
  end
  
  ou.cmd_str = pm.cmd_str;

  ou.ISI = ISI;       % save the results in a struct named "ou"
  save('-v7', output_fn, 'ou');
  s=datestr(now, 30);
  save('-v7', [output_fn '.finished'], 's');
