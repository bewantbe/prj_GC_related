% Test the correctness of approximate GC from spectrum

mode_IF = 'IF';
mode_ST = 0;
netstr = 'net_3_06';
scee = 0.01;
pr = 1;
ps = 0.012;
simu_time = 1e7;
stv = 1.0;
extst = '--RC-filter';

ext_T = 1e4;
[X, ISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time+ext_T, stv, extst);
X = X(:, round(ext_T/stv)+1:end);
if ~isempty(ras)
  ras(ras(:,2)<=ext_T, :) = [];
end
for id_p = 1:size(X,1)
  ISI(id_p) = simu_time/(sum(ras(:,1)==id_p,1));
end
[p, len] = size(X);
Xst = SpikeTrains(ras, p, len, stv);

%gc = nGrangerT(X, 20)
gc = nGrangerT(WhiteningFilter(Xst, 20), 20)
gc = nGrangerT(Xst, 20)

fftlen = lowest_smooth_number_exact(1.0*sqrt(len));
%S = mX2S_wnd(X, [fftlen, 0.5], @(x) 1-2*abs(x));
S = mX2S_wnd(Xst, fftlen);
gc_app = getGCSapp(S, 20)
