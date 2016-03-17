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
    covz_orig = covz;

    [GC De A2d] = RGrangerTfast(R);
    bigR = covz_orig(p+1:end, p+1:end);
end
toc;

% analyse x <- y
id_x = 1;
id_y = 2;

id_bt2tb = reshape(1:p*m, p, [])'(:);

gc_xy = expm1(GC(id_x, id_y))

% prepare toeplitz block matrix
erv3 = covz_orig(id_x, id_bt2tb+p);
eR3 = bigR(id_bt2tb, id_bt2tb);

id_bx = (1:m) + (id_x-1)*m;
id_by = (1:m) + (id_y-1)*m;
id_bz = 1:p*m;
id_bz([id_bx id_by]) = [];

Q = inv(eR3);

function MatShow(A)
  imagesc(A); colorbar; caxis([-1 1]*1e-3*max(abs(A(:))));
end

figure(11); MatShow(bigR);
figure(12); MatShow(inv(bigR));
figure(13); MatShow(eR3);
figure(14); MatShow(Q);

a12 = erv3 * Q(:, id_by);

figure(1); plot(a12);
err_coef = maxerr( a12 + A2d(id_x, id_y:p:end) )

gc_xy_exact = a12 / Q(id_by, id_by) * a12' / De(1,1)
err_gc_exact = maxerr(gc_xy - gc_xy_exact)

% approximation

A3d = cat(3, eye(p), reshape(A2d,p,p,[]));
A3d(:,:,end) = [];
M = zeros(size(Q));
G = zeros(size(Q));
for k=0:m-1
  M(k*p+1:(k+1)*p, k*p+1:end) = reshape(A3d(:,:,1:end-k), p, []);
  G(k*p+1:(k+1)*p, k*p+1:(k+1)*p) = De;
end

iG = inv(G);

%di = inv(bigR) - M'*iG*M;
%figure(2); imagesc( di(1:end-fit_od*p, 1:end-fit_od*p) ); colorbar

M  = M (id_bt2tb, id_bt2tb);
iG = iG(id_bt2tb, id_bt2tb);

Qyy_mapp = M(:, id_by)'*iG*M(:, id_by);  % the approximation
di = Q(id_by, id_by) - Qyy_mapp;

figure(3); imagesc(di(1:end-fit_od, 1:end-fit_od)); colorbar

gc_mapp = a12 / Qyy_mapp * a12' / De(id_x,id_x)
err_gc_mapp = maxerr(gc_mapp - gc_xy)

%%%%%%%%%%%%%%%
% get pairwise GC coef


