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

  X = SpikeTrainsFast(ras, p, len, pm.stv);

  % whiten the covariance in frequency domain
  covz = getcovzpd(X, fit_od);  clear X
  %[A2d, De] = ARregressionpd(covz, p);

  % purify coef
  [GC De A2d] = RGrangerTfast(covz, p);
  id_no_conn = GC < 2*fit_od/len;
  id_no_conn(eye(p)==1) = 0;
  id_a_zero = find(id_no_conn);
  A2d(bsxfun(@plus, id_a_zero, 0:p*p:end-1)) = 0;
  De(eye(p)==0) = 0;

  %S = A2S(A2d, De, max(pow2ceil(8*use_od), 1024));
  %S = StdWhiteS(S);
  %R = S2cov(S, use_od);  clear S
  %covz = R2covz(R);


    HTR = @(x) permute(conj(x), [2, 1, 3:ndims(x)]);
    S_orig = A2S(A2d, De, max(pow2ceil(8*use_od), 1024));
    %H_single_fact_S = zeros(size(S_orig));
    %A_single_fact_S = zeros(size(S_orig));
    Qw = zeros(size(S_orig));
    for k = 1:size(S_orig,3)
        Qw(:,:,k) = inv(S_orig(:,:,k));
    end
    H_single_fact_Q = zeros(size(S_orig));
    A_single_fact_Q = zeros(size(S_orig));
    for k= 1:p
      %H_single_fact_S(k,k,:) = S2H1D(squeeze(S_orig(k,k,:)));
      %A_single_fact_S(k,k,:) = 1 ./ H_single_fact_S(k,k,:);
      H_single_fact_Q(k,k,:) = S2H1D(squeeze(Qw(k,k,:)));
      A_single_fact_Q(k,k,:) = 1 ./ H_single_fact_Q(k,k,:);
    end
    A3d_w = fft( cat(3, eye(p), reshape(A2d, p,p,[])), size(S_orig,3), 3);
    %A_w = mult3d(A3d_w, H_single_fact_S);  disp('whiten in S')
    A_w = mult3d(A3d_w, A_single_fact_Q);  disp('whiten in Q');
    A3d = ifft(A_w, size(S_orig,3), 3);
    A2d = reshape(real(A3d(:,:,2:use_od+1)), p, []);  % overwrite A2d

    %S = mult3d(A_single_fact_S, S_orig, HTR(A_single_fact_S));
    S = mult3d(H_single_fact_Q, S_orig, HTR(H_single_fact_Q));
    %S = S_orig;
    for k=1:p
      S(k,k,:) = real(S(k,k,:));
    end
    R = S2cov(S, use_od);
    covz = R2covz(R);


  [GC De A2d] = RGrangerTfast(R);
  bigR = covz(p+1:end, p+1:end);  clear covz

  %id_bt2tb = reshape(1:p*m, p, [])'(:);
  id_bt2tb = reshape(1:p*m, p, [])';
  %id_bt2tb = id_bt2tb(:);
  % prepare toeplitz block matrix
  eR3 = bigR(id_bt2tb, id_bt2tb);
  Q = inv(eR3);

  A2d_I = [eye(p) A2d(:, 1:end-p)];
  invDe = inv(De);
  M = zeros(size(Q));
  iG = sparse(p*m, p*m);
  for k=0:m-1
    M(k*p+1:(k+1)*p, k*p+1:end) = A2d_I(:,1:end-k*p);
    iG(k*p+1:(k+1)*p, k*p+1:(k+1)*p) = invDe;
  end
  %iG = inv(G);

  %di = inv(bigR) - M'*iG*M;
  %figure(4); imagesc( di(1:end-fit_od*p, 1:end-fit_od*p) ); colorbar

  M  = M (id_bt2tb, id_bt2tb);
  iG = iG(id_bt2tb, id_bt2tb);

end
toc; tic;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% is inverse of covariance sparse

if 1
  figure(11); MatShow(bigR);
  figure(12); MatShow(inv(bigR));
  figure(13); MatShow(eR3);
  figure(14); MatShow(Q);

  arr= sumBlock(Q, m, p);

  % Compare Q to adj
  figure(5);
  MatShow(arr, 2e-3);
  figure(6);
  adj = pm.net_adj*1;
  MatShow(adj'+adj+eye(p), 0.1);

  figure(7);
  MatShow(arr, 5e-5);
  figure(8);
  adj_e = pm.net_adj*1 + eye(p);
  MatShow(adj_e'*adj_e, 0.1);

  % Verify M block to adj
  figure(15);
  MatShow(M, 0.001);
  figure(16);
  MatShow(adj_e, 0.001);
  figure(17);
  arr2 = sumBlock(M, m, p);
  MatShow(arr2,0.02);
  maxerr((arr2>1e-10) - (adj_e))

  % Different level of Q
  figure(21);
  semilogy(sort(arr(:)), '-o')
  figure(22);
  arr4 = sumBlock(M'*iG*M, m, p);
  semilogy(sort(arr4(:)), '-o')

  % Adj for different level of Q
  net_h1 = zeros(p); net_h1(10<arr) = 1;
  net_h2 = zeros(p); net_h2(0.1<arr & arr<10) = 1;
  net_h3 = zeros(p); net_h3(1e-3<arr & arr<0.1) = 1;
  net_h4 = zeros(p); net_h4(arr<1e-3) = 1;
  figure(31);  MatShow(net_h1);
  figure(32);  MatShow(net_h2);
  figure(33);  MatShow(net_h3);
  figure(34);  MatShow(net_h4);

  % Guessed by adjacency matrix
  figure(41);  MatShow(eye(p));
  figure(42);  MatShow(adj'+adj);
  figure(43);  MatShow(1*((1*(adj'*adj>0) - 1*((eye(p) + adj' + adj)>0))>0));
end

%%%%%%%%%%%%%%%%
% analyse GC: x <- y
id_x = 2;
id_y = 7;

id_bx = (1:m) + (id_x-1)*m;
id_by = (1:m) + (id_y-1)*m;
id_bz = 1:p*m;
id_bz([id_bx id_by]) = [];

% a12 coef verification
erv3 = R(id_x, id_bt2tb+p);
a12 = erv3 * Q(:, id_by);

figure(1); plot(a12);
err_coef = maxerr( a12 + A2d(id_x, id_y:p:end) )

% GC verification
gc_xy = expm1(GC(id_x, id_y))
gc_xy_exact = a12 / Q(id_by, id_by) * a12' / De(id_x,id_x)
err_gc_exact = maxerr(gc_xy - gc_xy_exact)

% GC approximation
Qyy_mapp = M(:, id_by)'*iG*M(:, id_by);
di = Q(id_by, id_by) - Qyy_mapp;

figure(3); imagesc(di(1:end-fit_od, 1:end-fit_od)); colorbar

gc_mapp = a12 / Qyy_mapp * a12' / De(id_x,id_x)
err_gc_mapp = maxerr(gc_mapp - gc_xy)

toc; tic

%%%%%%%%%%%%%%%%%%%%%%%%%%
% get pairwise GC

%R_xy_ = S2cov(S([id_x id_y],[id_x id_y],:), m);
R_xy = R([id_x id_y], bsxfun(@plus, [id_x id_y]', 0:p:end-1));
%maxerr(R_xy - R_xy_)
[pairGC D_B B] = RGrangerTfast(R_xy);
gc_pair = expm1(pairGC(1,2))

%%%%%%%%%%%%%%%%%%%%%%%%%%
% get pairwise coef

a13_mapp = erv3 * Q(:, id_bz);

b12 = -B(1, 2:2:end);
figure(51); plot(b12);

% the answer
b12_Q = a12 - a13_mapp / Q(id_bz,id_bz) * Q(id_bz, id_by);
% the approximation
Qzz_mapp = M(:, id_bz)'*iG*M(:, id_bz);
Qzy_mapp = M(:, id_bz)'*iG*M(:, id_by);
b12_mapp = a12 - a13_mapp / Qzz_mapp * Qzy_mapp;
err_b12_mapp = maxerr(b12 - b12_mapp)
figure(52); plot(b12 - b12_mapp);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% gc app

% the answers
P = inv(eR3([id_bx id_by], [id_bx id_by]));
gc_pair_P = b12 / P(m+1:end, m+1:end) * b12' / D_B(1,1)
%gc_pair_Q = b12 / (Q(id_by,id_by) - Q(id_by,id_bz)/Q(id_bz,id_bz)*Q(id_bz,id_by)) * b12' / D_B(1,1)

% the approximation
Qyz_mapp = M(:, id_by)'*iG*M(:, id_bz);
gc_pair_mapp = b12_mapp / (Qyy_mapp - Qyz_mapp/Qzz_mapp*Qzy_mapp) * b12_mapp' / D_B(1,1)
gc_pair_mapp2 = b12_mapp / Qyy_mapp * b12_mapp' / D_B(1,1)
err_gc_pair_mapp = maxerr(gc_pair - gc_pair_mapp)

%covz_xy = R2covz(R_xy);
%id_xy_re = reshape(1:2*m, 2, [])'(:);
%RR = covz_xy(id_xy_re, id_xy_re);
%maxerr(RR - eR3([id_bx id_by], [id_bx id_by]))

pm.net_adj(id_x, id_y)
m

clear Qzz_mapp
toc
