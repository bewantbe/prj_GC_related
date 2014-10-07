
% common parameters for neuron network
pm = [];
pm.neuron_model = 'LIF';
pm.net  = 'net_10_1';
pm.nI   = 2;
pm.scee = 0.005;
pm.scie = 0.005;
pm.scei = 0.007;
pm.scii = 0.007;
pm.pr   = 1.0;
pm.ps   = 0.007;
pm.t    = 1e6;
pm.stv  = 0.5;

net_param.generator  = 'gen_sparse';
net_param.p          = 100;
net_param.sparseness = 0.20;  % 0.20 0.15 0.10 0.05
net_param.seed       = 123;
net_param.software   = myif(exist('OCTAVE_VERSION','builtin'), 'octave', 'matlab');
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

clear('pm');
pm.neuron_model = 'HH3_gcc';
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
[p, len] = size(X);

b_use_spike_train = false;
% Convert to spike train if requested
if b_use_spike_train
  clear('X');
  X = SpikeTrains(ras, p, len, pm.stv);
end

aic_od = chooseOrderAuto(X,'AIC');
bic_od = chooseOrderAuto(X,'BIC');
srd = WhiteningFilter(X, aic_od);

fprintf('X: aic od = %d, bic_od = %d\n', aic_od, bic_od);

% the fitting order used to calculate GC
use_od = aic_od;

covz = getcovz(srd, use_od);  % 40.4 sec for p=100, od=30
R = covz(1:p, 1:end);

p0 = 10;

% 62.6 s for p=100, od=30
[GC_srd_covz, Deps, AA] = pos_nGrangerT2RZ(covz, p);
figure(1);
%GC_hist(GC_srd_covz, pm.net_adj, pm.nE);
GC_hist(GC_srd_covz(1:p0, 1:p0), pm.net_adj(1:p0, 1:p0), p0);

GC_srd_pairs = pairRGrangerT(R);  % 9.13 s for p=100, od=30
figure(2);
%GC_hist(GC_srd_pairs(1:p0, 1:p0), pm.net_adj, pm.nE);
GC_hist(GC_srd_pairs(1:p0, 1:p0), pm.net_adj(1:p0, 1:p0), p0);

tic
O = zeros(p0, p0);
s_GC_fomula = O;
s_quotient_core = O;
s_quotient_core_app = O;
s_quotient_core_expension_od2_v1 = O;
s_quotient_core_expension_od1_v1 = O;
s_quotient_core_expension_od1_v2 = O;
s_GC_approx_od2 = O;
s_GC_approx_od2_wrong = O;
s_GC_approx_od1 = O;
s_quotient_core_expension_od4_v1 = O;
for ii=1:size(O,1)
  for jj=1:size(O,2)
    if (ii == jj)
      continue;
    end
    [GC_fomula, quotient_core, quotient_core_app, quotient_core_expension_od2_v1, quotient_core_expension_od1_v1, quotient_core_expension_od1_v2, GC_approx_od2, GC_approx_od2_wrong, GC_approx_od1, quotient_core_expension_od4_v1] = GC3var(ii, jj, covz, p);
    s_GC_fomula(ii,jj) = GC_fomula;
    s_quotient_core(ii,jj) = quotient_core;
    s_quotient_core_app(ii,jj) = quotient_core_app;
    s_quotient_core_expension_od2_v1(ii,jj) = quotient_core_expension_od2_v1;
    s_quotient_core_expension_od1_v1(ii,jj) = quotient_core_expension_od1_v1;
    s_quotient_core_expension_od1_v2(ii,jj) = quotient_core_expension_od1_v2;
    s_GC_approx_od2(ii,jj) = GC_approx_od2;
    s_GC_approx_od2_wrong(ii,jj) = GC_approx_od2_wrong;
    s_GC_approx_od1(ii,jj) = GC_approx_od1;
    s_quotient_core_expension_od4_v1(ii,jj) = quotient_core_expension_od4_v1;
  end
end
toc
figure(3);
%GC_hist(s_GC_fomula, pm.net_adj, pm.nE);
GC_hist(s_GC_fomula, pm.net_adj(1:p0, 1:p0), p0);

