% Generate HH data

disp('------------------ generating data ------------------');
fflush(stdout);

clear('X','ras','ISI');
% cost 12 sec for 100neu * 2e6sample
[X, ISI, ras, pm] = gen_HH(pm, 'ext_T');

% Down sampling the voltage, in case we don't want to regenerate it
if i_stv ~= 1
  X = X(:, 1:i_stv:end);
  pm.stv = pm.stv * i_stv;
end

[p, len] = size(X);

% Convert to spike train if requested
% cost 34 sec for 100neu * 2e6sample
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
  fprintf('mean ISI = %.2f (std=%.2f)\n', mean(ISI), std(ISI));
end
fflush(stdout);

%[zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od, pm);
[zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od, pm, b_use_spike_train, ISI, '_od40', 'GCinfo');

