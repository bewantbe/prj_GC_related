% Time domain app

pow2ceil = @(x) 2^ceil(log2(x));
maxerr = @(x) max(abs(x(:)));

fit_od = 40;
use_od = 200;
m = use_od;

%ed = 0;
if ~exist('ed', 'var') || isempty(ed) || ~ed
  ed = true;

  %gen_data_n10_c1;
  %gen_data_n40_c1;  % 1 40
  gen_data_n100_c1;  % 32  32

  len = size(X,2);

  tic
  covz = getcovzpd(X, fit_od);  clear X
  toc
  [A2d, De] = ARregressionpd(covz, p);
  S = A2S(A2d, De, max(pow2ceil(8*use_od), 1024));
%  S = StdWhiteS(S);
  R = S2cov(S, use_od);  clear S
  tic
  [GC De A2d] = RGrangerTfast(R);
  toc
end

% GC verification
id_x = 2;
id_y = 8;

fprintf('Number of variates: %d\n', p);
fprintf('Extended fitting order: %d\n', m);
fprintf('Net edge(%d, %d) = %d\n', id_x, id_y, pm.net_adj(id_x, id_y));

% The answers
gc_xy = expm1(GC(id_x, id_y));
R_xy = R([id_x id_y], bsxfun(@plus, [id_x id_y]', 0:p:end-1));
[pairGC D_B B] = RGrangerTfast(R_xy);
b12 = -B(1, 2:2:end);
gc_pair = expm1(pairGC(1,2));

% The approximation
tic
[gc_mapp, b12_mapp, gc_pair_mapp] = GC_mapp(A2d, De, id_x, id_y);
toc

%figure(10); plot(1:m, b12, 1:m, b12_mapp);

% errors
err_gc_mapp = maxerr(gc_mapp - gc_xy);
fprintf('  Err GC mapp     : %.1e (true = %.2e)\n', err_gc_mapp, gc_xy);
err_b12_mapp = maxerr(b12 - b12_mapp);
fprintf('  Err B12 mapp    : %.1e (true = %.2e)\n', err_b12_mapp, max(abs(b12)));
err_gc_pair_mapp = maxerr(gc_pair - gc_pair_mapp);
fprintf('  Err pair GC mapp: %.1e (true = %.2e)\n', err_gc_pair_mapp, gc_pair);

tic
fftlen = 1024;
[gc_sapp, b12_sapp, gc_pair_sapp] = GC_sapp(A2d, De, id_x, id_y, fftlen);
toc

% errors
err_gc_sapp = maxerr(gc_sapp - gc_xy);
fprintf('  Err GC sapp     : %.1e (true = %.2e)\n', err_gc_sapp, gc_xy);
err_b12_sapp = maxerr(b12 - b12_sapp);
fprintf('  Err B12 sapp    : %.1e (true = %.2e)\n', err_b12_sapp, max(abs(b12)));
err_gc_pair_sapp = maxerr(gc_pair - gc_pair_sapp);
fprintf('  Err pair GC sapp: %.1e (true = %.2e)\n', err_gc_pair_sapp, gc_pair);

figure(11); plot(1:m, b12, 1:m, b12_mapp, 1:m, b12_sapp); legend('b12', 'mapp', 'sapp');
figure(12); plot(1:m, b12_mapp-b12, 1:m, b12_sapp-b12); legend('diff mapp', 'diff sapp');

