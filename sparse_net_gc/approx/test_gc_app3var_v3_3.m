% Time domain app

pow2ceil = @(x) 2^ceil(log2(x));
maxerr = @(x) max(abs(x(:)));

fit_od = 40;
use_od = 200;
m = use_od;

ed = 0;
tic;
if ~exist('ed', 'var') || isempty(ed) || ~ed
  ed = true;

  gen_data_n10_c1;
  %gen_data_n40_c1;  % 1 40
  %gen_data_n100_c1;  % 32  32

  len = size(X,2);

  % whiten the covariance in frequency domain
  covz = getcovzpd(X, fit_od);  clear X
  %[A2d, De] = ARregressionpd(covz, p);

  % purify coef
  [GC De A2d] = RGrangerTfast(covz, p);
  %id_no_conn = GC < 2*fit_od/len;
  %id_no_conn(eye(p)==1) = 0;
  %id_a_zero = find(id_no_conn);
  %A2d(bsxfun(@plus, id_a_zero, 0:p*p:end-1)) = 0;
  %De(eye(p)==0) = 0;

  S = A2S(A2d, De, max(pow2ceil(8*use_od), 1024));
  %S = StdWhiteS(S);
  R = S2cov(S, use_od);  clear S
  covz = R2covz(R);

  [GC De A2d] = RGrangerTfast(R);

end
toc; tic;

tic;
% GC verification
id_x = 2;
id_y = 6;

% The answers
gc_xy = expm1(GC(id_x, id_y));
R_xy = R([id_x id_y], bsxfun(@plus, [id_x id_y]', 0:p:end-1));
[pairGC D_B B] = RGrangerTfast(R_xy);
b12 = -B(1, 2:2:end);
gc_pair = expm1(pairGC(1,2));

[gc_mapp, b12_mapp, gc_pair_mapp] = GC_mapp(A2d, De, id_x, id_y);

err_gc_mapp = maxerr(gc_mapp - gc_xy)
err_b12_mapp = maxerr(b12 - b12_mapp)
err_gc_pair_mapp = maxerr(gc_pair - gc_pair_mapp)

pm.net_adj(id_x, id_y)
m

toc
