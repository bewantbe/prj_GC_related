%sub net case

% Generate HH data
% work with GCHH_analyse_core.m

net_param.generator  = 'gen_sparse';
net_param.p          = 1000;
net_param.sparseness = 0.025;  % 0.30 0.20 0.15 0.10 0.05
net_param.seed       = 123;
net_param.software   = myif(exist('OCTAVE_VERSION','builtin'), 'octave', 'matlab');
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

i_stv   = 1;  % Down sampling factor

clear('pm');
pm.neuron_model = 'HH3_gcc49_sparse';
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = floor(net_param.p * 0.25);
pm.scee = 0.04;
pm.scie = 0.04;
pm.scei = 0.07;
pm.scii = 0.07;
pm.pr   = 0.7;
pm.ps   = 0.032;  % 0.032 = 1 mV
pm.t    = 1e6;
pm.stv  = 0.5;

max_od = 40;

net_param.sparseness = 0.10;
net_param.sparseness = 0.05;
pm.net_param = net_param;
pm.net = gen_network(net_param);
b_use_spike_train = false;

clear('X','ras','ISI');
% cost 128 sec for 1000neu * 2e6sample
[X, ISI, ras, pm] = gen_HH(pm, 'ext_T');

subnet_var_idx = 1:100;
X = X(subnet_var_idx, :);
pm.net_adj_full = pm.net_adj;
pm.net_adj = pm.net_adj(subnet_var_idx, subnet_var_idx);
pm.subnet_var_idx = subnet_var_idx;
pm.nE_full = pm.nE;
pm.nI_full = pm.nI;
mei = [ones(1,pm.nE), zeros(1,pm.nI)];
pm.nE = sum(mei(subnet_var_idx)==1);
pm.nI = sum(mei(subnet_var_idx)==0);

[p, len] = size(X);

if b_use_spike_train
  clear('X');
  X = SpikeTrains(ras, p, len, pm.stv);
end

fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
        pm.net, pm.scee, pm.pr, pm.ps, pm.t, pm.stv, len);

tic; [zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od, pm, b_use_spike_train, ISI,...
   ['_od', num2str(max_od), '_sub1t100'], 'GCinfo'); toc; % 88sec


