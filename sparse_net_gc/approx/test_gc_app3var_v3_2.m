% Time domain app

pow2ceil = @(x) 2^ceil(log2(x));
maxerr = @(x) max(abs(x(:)));

fit_od = 40;
use_od = 120;
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
  covz = getcovzpd(X, fit_od);
  %[A2d, De] = ARregressionpd(covz, p);

  % purify coef
  [GC De A2d] = RGrangerTfast(covz, p);
  id_no_conn = GC < 2*fit_od/len;
  id_no_conn(eye(p)==1) = 0;
  id_a_zero = find(id_no_conn);
  A2d(bsxfun(@plus, id_a_zero, 0:p*p:end-1)) = 0;
  De(eye(p)==0) = 0;

  S = A2S(A2d, De, max(pow2ceil(8*use_od), 1024));
  %S = StdWhiteS(S);
  R = S2cov(S, use_od);
  covz = R2covz(R);

  [GC De A2d] = RGrangerTfast(R);
  bigR = covz(p+1:end, p+1:end);

  id_bt2tb = reshape(1:p*m, p, [])'(:);
  % prepare toeplitz block matrix
  eR3 = bigR(id_bt2tb, id_bt2tb);
  Q = inv(eR3);

  function MatShow(A, err)
    if ~exist('err','var')
      err = 1e-3;
    end
    imagesc(A); colorbar; caxis([-1 1]*err*max(abs(A(:))));
  end

  figure(11); MatShow(bigR);
  figure(12); MatShow(inv(bigR));
  figure(13); MatShow(eR3);
  figure(14); MatShow(Q);

  A3d = cat(3, eye(p), reshape(A2d,p,p,[]));
  A3d(:,:,end) = [];
  M = zeros(size(Q));
  G = zeros(size(Q));
  for k=0:m-1
    M(k*p+1:(k+1)*p, k*p+1:end) = reshape(A3d(:,:,1:end-k), p, []);
    G(k*p+1:(k+1)*p, k*p+1:(k+1)*p) = De;
  end
  iG = inv(G);

  di = inv(bigR) - M'*iG*M;
  figure(4); imagesc( di(1:end-fit_od*p, 1:end-fit_od*p) ); colorbar

  M  = M (id_bt2tb, id_bt2tb);
  iG = iG(id_bt2tb, id_bt2tb);

end
toc;

% analyse x <- y
id_x = 1;
id_y = 6;

id_bx = (1:m) + (id_x-1)*m;
id_by = (1:m) + (id_y-1)*m;
id_bz = 1:p*m;
id_bz([id_bx id_by]) = [];

% a12 coef verification
erv3 = covz(id_x, id_bt2tb+p);
a12 = erv3 * Q(:, id_by);

figure(1); plot(a12);
err_coef = maxerr( a12 + A2d(id_x, id_y:p:end) )

% GC verification
gc_xy = expm1(GC(id_x, id_y))
gc_xy_exact = a12 / Q(id_by, id_by) * a12' / De(1,1)
err_gc_exact = maxerr(gc_xy - gc_xy_exact)

% GC approximation
Qyy_mapp = M(:, id_by)'*iG*M(:, id_by);
di = Q(id_by, id_by) - Qyy_mapp;

figure(3); imagesc(di(1:end-fit_od, 1:end-fit_od)); colorbar

gc_mapp = a12 / Qyy_mapp * a12' / De(id_x,id_x)
err_gc_mapp = maxerr(gc_mapp - gc_xy)

%% is inverse of covariance sparse

% sum blocks of m*m
arr = permute(reshape(Q, m, p, m, p), [1 3 2 4]);
arr = squeeze(sum(reshape(abs(arr), m*m, p, p)));
arr(eye(p)==1) = 0;

figure(5);
MatShow(arr, 0.1);
figure(6);
adj = pm.net_adj*1;
MatShow(adj'+adj, 0.1);

figure(7);
MatShow(arr, 0.001);
figure(8);
adj_e = pm.net_adj*1 + eye(p);
MatShow(adj_e'*adj_e, 0.1);

figure(14);
MatShow(M, 0.001);
figure(15);
MatShow(adj_e, 0.001);

%%%%%%%%%%%%%%%
% get pairwise GC coef

