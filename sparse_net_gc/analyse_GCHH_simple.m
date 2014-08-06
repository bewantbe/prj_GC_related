% Generate HH data

disp('------------------ generating data ------------------');

net_param.generator  = 'gen_sparse';
net_param.p          = 100;
net_param.sparseness = 0.05;  % 0.2 0.1 0.05
net_param.seed       = 123;
net_param.software   = myif(exist('OCTAVE_VERSION','builtin'), 'octave', 'matlab');
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

b_use_spike_train = false;
i_stv   = 1;  % Down sampling factor

clear('pm');
pm.neuron_model = 'HH';
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = 20;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.09;
pm.scii = 0.09;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = 1e6;
pm.stv  = 0.5;

[X, ISI, ras, pm] = gen_HH(pm, 'ext_T');

%[X, ISI, ras, pm] = gen_HH(pm, 'ext_T, rm');
%return;

% Down sampling the voltage, in case we don't want to regenerate it
if i_stv ~= 1
  X = X(:, 1:i_stv:end);
  pm.stv = pm.stv * i_stv;
end

[p, len] = size(X);

% Convert to spike train if requested
if b_use_spike_train
  clear('X');
  X = SpikeTrains(ras, p, len, pm.stv);
end

fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
        pm.net, pm.scee, pm.pr, pm.ps, pm.t, pm.stv, len);
if p < 8
  disp('ISI:');
  disp(ISI);
else
  fprintf('mean ISI = %f (std=)\n', mean(ISI), std(ISI));
end

max_od = 30;

%[zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od, pm);
[zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od, pm, b_use_spike_train, ISI, '_test', 'GCinfo');

