
% common parameters for neuron network
pm = [];
%pm.neuron_model = 'HH3_gcc';
%pm.net  = 'net_10_1';
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

covz = getcovz(srd, use_od);
R = covz(1:p, 1:end);

[GC_srd_covz, Deps, AA] = pos_nGrangerT2RZ(covz, p);
figure(1);
GC_hist(GC_srd_covz, pm.net_adj, pm.nE)

GC_srd_pairs = pairRGrangerT(R);
figure(2);
GC_hist(GC_srd_pairs, pm.net_adj, pm.nE)

GC_app = zeros(p, p);
for ii=1:p
  for jj=1:p
    GC_app(ii, jj) = GC3var(ii, jj, covz, p);
  end
end
figure(3);
GC_hist(GC_app, pm.net_adj, pm.nE)

