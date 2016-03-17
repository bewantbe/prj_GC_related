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

    % whiten the covariance in frequency domain
    [A2d, D] = ARregressionpd(getcovzpd(X, fit_od), p);
    S = A2S(A2d, D, max(pow2ceil(8*use_od), 1024));
    %S = StdWhiteS(S);
    R = S2cov(S, use_od);
    covz = R2covz(R);
    covz_orig = covz;

    [GC De A] = RGrangerTfast(R);
    bigR = covz_orig(p+1:end, p+1:end);
end
toc;

% analyse x <- y
id_x = 1;
id_y = 2;

id_z = 1:p;
id_z([id_x id_y]) = [];
permvec = [id_x id_y id_z];
id_rearrange = bsxfun(@plus, permvec', p*(0:m-1))(:);
id_p = 0 : p : p*m-1;
id_p_3 = bsxfun(@plus, [3:p]', p*(0:m-1))(:).';

gc_xy = expm1(GC(id_x, id_y))

% prepare toeplitz block matrix
R11 = bigR(id_p+1, id_p+1);
R12 = bigR(id_p+1, id_p+2);
R13 = bigR(id_p+1, id_p_3);
R22 = bigR(id_p+2, id_p+2);
R23 = bigR(id_p+2, id_p_3);
R33 = bigR(id_p_3, id_p_3);
r1O1 = covz_orig(1, id_p+1+p);
r1O2 = covz_orig(1, id_p+2+p);
r1O3 = covz_orig(1, id_p_3+p);

erv3 = [r1O1 r1O2 r1O3];
eR3 = [
    R11  R12  R13
    R12' R22  R23
    R13' R23' R33];

id_vx = (1:m);
id_vy = (1:m)+m;
id_vz = m+m+1 : size(eR3, 1);
Q = inv(eR3);
Qxy = Q(id_vx, id_vy);
Qyy = Q(id_vy, id_vy);
Qyz = Q(id_vy, id_vz);
Qzy = Q(id_vz, id_vy);
Qzz = Q(id_vz, id_vz);

a12 = (erv3 * Q)(m+1:2*m);

figure(1); plot(a12);
maxerr( a12(1:fit_od) + A2d(id_x, id_y:p:end) )

gc_xy_exact = a12 / Qyy * a12' / D(1,1)
maxerr(gc_xy - gc_xy_exact)

% approximation

A3d = cat(3, eye(p), reshape(A,p,p,[]));
A3d(:,:,end) = [];
M = zeros(size(Q));
for k=0:m-1
  M(k*p+1:(k+1)*p, k*p+1:end) = reshape(A3d(:,:,1:end-k), p, []);
end

G = zeros(size(Q));
for k=0:m-1
  G(k*p+1:(k+1)*p, k*p+1:(k+1)*p) = De;
end

%di = inv(covz_orig(p+1:end, p+1:end)) - M'*inv(G)*M;
di = inv(bigR) - M'*inv(G)*M;
figure(2); imagesc( di(1:end-fit_od*p, 1:end-fit_od*p) ); colorbar

M = M(id_rearrange, id_rearrange);
%Mxx = M(id_p+1, id_p+1);
%Mxy = M(id_p+1, id_p+2);
%Mxz = M(id_p+1, id_p_3);
%Myx = M(id_p+2, id_p+1);
%Myy = M(id_p+2, id_p+2);
%Myz = M(id_p+2, id_p_3);
%Mzx = M(id_p_3, id_p+1);
%Mzy = M(id_p_3, id_p+2);
%Mzz = M(id_p_3, id_p_3);

iG = inv(G);
%iGx = iG(id_p+1, id_p+1);
%iGy = iG(id_p+2, id_p+2);
%iGz = iG(id_p_3, id_p_3);

%Qyy_ = inv(bigR)(id_p+2, id_p+2);

%di = Qyy - (Mxy'*iGx*Mxy + Myy'*iGy*Myy + Mzy'*iGz*Mzy);  % approximation

%M_y = [Mxy; Myy; Mzy];
%di = Qyy - (M_y'*iG(id_3p,id_3p)*M_y);  % exact

%di = Qyy - (M(:, id_p+2)'*inv(G)*M(:, id_p+2));  % def

id_3p = [id_p+1 id_p+2 id_p_3];
di = Qyy - (M(id_3p, id_p+2)'*iG(id_3p,id_3p)*M(id_3p, id_p+2));

figure(3); imagesc(di(1:end-fit_od, 1:end-fit_od)); colorbar

