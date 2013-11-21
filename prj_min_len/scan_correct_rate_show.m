%

%fn_scan_data = 'scan_correct_net_2_2_sc=0.010_pr=0.90_ps=0.010_T=1.2e+05_stv=0.50_j10000.mat';
fn_scan_data = 'scan_correct_net_2_2_sc=0.010_pr=0.45_ps=0.010_T=9.0e+04_stv=0.50_j10000.mat';

pv = 1e-2;

load(fn_scan_data);
len = round(simu_time/stv);

net = getnetwork(netstr);
s_aic = zeros(size(s_jobs));
s_bic = zeros(size(s_jobs));
s_gc1_bic = zeros(size(s_jobs));
s_gc0_bic = zeros(size(s_jobs));
s_gc1_aic = zeros(size(s_jobs));
s_gc0_aic = zeros(size(s_jobs));
s_gc1_fixod = zeros(size(s_jobs));
s_gc0_fixod = zeros(size(s_jobs));
s_correct = zeros(size(s_jobs));

fixod = 27;
tic
for id_jobs=1:numel(s_jobs)
  da = s_data{id_jobs};
  [aic_od, bic_od, zero_GC] = AnalyseSeries2(s_od, da.oGC, da.oDe, len);
  net_guess = gc_prob_nonzero(da.oGC(:,:,bic_od),bic_od,len) >= 1-pv;
  s_correct(id_jobs) = all(net_guess(:) == net(:));
  s_aic(id_jobs) = aic_od;
  s_bic(id_jobs) = bic_od;
  s_gc1_bic(id_jobs) = da.oGC(2,1,bic_od);
  s_gc0_bic(id_jobs) = da.oGC(1,2,bic_od);
  s_gc1_aic(id_jobs) = da.oGC(2,1,aic_od);
  s_gc0_aic(id_jobs) = da.oGC(1,2,aic_od);
  s_gc1_fixod(id_jobs) = da.oGC(2,1,fixod);
  s_gc0_fixod(id_jobs) = da.oGC(1,2,fixod);
end
toc

fprintf('correct rate: %.1f%%\n\n', 100*sum(s_correct)/numel(s_jobs));

nbin = 100;
figure(1);
hist(s_aic, nbin);
xlabel('aic od');

figure(2);
hist(s_bic, nbin);
xlabel('bic od');

figure(3);
hist(s_gc1_aic, nbin);
xlabel('GC at aic');

figure(4);
hist(s_gc1_bic, nbin);
xlabel('GC at bic');

figure(5);
hist(s_gc1_fixod, nbin);
xlabel(sprintf('GC at %d', fixod));

