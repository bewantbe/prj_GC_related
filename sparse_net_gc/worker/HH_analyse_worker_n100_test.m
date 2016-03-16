% Generate HH data
% work with GCHH_analyse_core.m

net_param.generator  = 'gen_sparse_mt19937';
net_param.p          = 100;
net_param.sparseness = 1/net_param.p;
net_param.seed       = 423;
net_param.software   = 'MT19937';
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

b_use_spike_train = false;
i_stv   = 1;  % Down sampling factor

clear('pm');
pm.neuron_model = 'HH3_gcc49_westmere2';
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = round(0.2*net_param.p);
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.10;
pm.scii = 0.10;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = 1e5;
pm.stv  = 0.5;

max_od = 40;

[X, ISI, ras, pm] = gen_HH(pm, 'ext_T');

fftlen = [1024, 0.5];       % 50% overlap
f_wnd = @(x) 1 - 2*abs(x);  % bartlet window
tic;
S = mX2S_wnd(X, fftlen, f_wnd);
fprintf('t = %.3f, cal spectrum\n', toc);

addpath('/home/xyy/Dropbox/group share(unformal)/Wilson factorization code/');

TOL = 1e-12;
t0 = tic;
[Sigma,H,rHv] = WIfacS(S, TOL);
fprintf('t = %.3f, cal spectrum\n', (double(tic()) - double(t0))*1e-6);

