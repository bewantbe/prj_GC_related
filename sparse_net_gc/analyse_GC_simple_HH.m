% Generate HH data

disp('------------------ generating data ------------------');

net = gen_sparse(3, 0.1, 123);

neuron_model      = 'HH';
b_use_spike_train = false;
i_stv   = 1;  % Down sampling factor

clear('pm');
pm.net  = net;
pm.nI   = 1;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.06;
pm.scii = 0.06;
pm.pr   = 1.6;
pm.ps   = 0.04;
pm.t    = 1e5;
pm.stv  = 0.5;

[X, ISI, ras, pm] = gen_HH(pm, 'ext_T');

% Down sampling the voltage, in case we don't want to regenerate it
if i_stv ~= 1
  X = X(:, 1:i_stv:end);
  pm.stv = pm.stv * i_stv;
end

% Convert to spike train if requested
if b_use_spike_train
  [p, len] = size(X);
  clear('X');
  X = SpikeTrains(ras, p, len, pm.stv);
end

[p, len] = size(X);
if ischar(pm.net)
  netname = pm.net;
else
  netname = 'custom';
end
fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
  netname, pm.scee, pm.pr, pm.ps, pm.t, pm.stv, len);
disp('ISI:');
disp(ISI);

max_od = 30;  % for IF

%[zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od, pm);
[zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od, pm, neuron_model, b_use_spike_train, ISI, '_test', 'GCinfo');

