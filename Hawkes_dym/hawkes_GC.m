% fixed parameters
addpath([getenv('HOME') '/code/point-neuron-network-simulator/mfile/']);
addpath([getenv('HOME') '/matcode/GC_clean/GCcal/']);

set(0, 'defaultlinelinewidth', 2);
set(0, 'defaultaxesfontsize', 22);

pm = [];
pm.neuron_model = 'Hawkes-GH';
pm.simu_method = 'simple';
pm.net     = 1 - eye(3);
pm.nI      = 1;
pm.scee    = 0.15;
pm.scie    = 0.15;
pm.scei    = 0.1;
pm.scii    = 0.1;
pm.ps      = 0.05;
pm.pr      = 0;
pm.t       = 1e6;
pm.seed    = 123354;
pm.extra_cmd = '-v --verbose-echo';
%pm.extra_cmd = '-v';

[X, ISI, ras, pm] = gen_neu(pm, 'rm');

fprintf('fr = %.3g Hz\n', 1000 ./ ISI);

s_t = (1:length(X))/pm.stv;

%figure(1);
%plot(s_t, X);

q1 = diff(ras(ras(:,1)==1,2));
q2 = diff(ras(ras(:,1)==2,2));

%figure(2);
%hist(q, 1000);

mean(q1)
mean(q2)

st_stv = 0.25;
st = SpikeTrains(ras, size(X, 1), pm.t/st_stv, st_stv, 1);
od = 15/st_stv;
[GC, De, A] = nGrangerTfast(st, od);

De
mean(st')

fge = @(t, tC, tCR) (exp(-t/tC) - exp(-t/tCR)) * (tC * tCR / (tC - tCR));
fgi = @(t, tC, tCR) (exp(-t/tC) - exp(-t/tCR)) * (tC * tCR / (tC - tCR));

t_a = 1:od;

p = size(X, 1);

for ii = 1:p
  for jj = 1:p
    figure(30+p*ii+jj);
    if (jj <= pm.nE)
      plot(t_a, A(ii, jj:p:end), '-o', t_a, -st_stv * pm.net_adj(ii, jj) * pm.scee * fge(t_a * st_stv, 4.0, 0.5), '-o');
    else
      plot(t_a, A(ii, jj:p:end), '-o', t_a,  st_stv * pm.net_adj(ii, jj) * pm.scei * fge(t_a * st_stv, 4.0, 0.5), '-o');
    end
    xlabel(sprintf("coef: %d -> %d", jj, ii));
  end
end

