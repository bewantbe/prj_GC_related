%
pow2ceil = @(x) 2^ceil(log2(x));
maxerr = @(x) max(abs(x(:)));
HTR = @(x) permute(conj(x), [2, 1, 3:ndims(x)]);
%ed = 0;

if ~exist('ed', 'var') || isempty(ed) || ~ed
ed = true;

%gen_data_n10_c1;
%gen_data_n40_c1;  % 1 40
gen_data_n100_c1;  % 32  32

[p len] = size(X);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocessing and get spectrum, R and covz
fit_od = 80;
use_od = 600;
whiten_od = 80;

mode_preprocessing = 5;
tic
switch mode_preprocessing
  case 1
    X = WhiteningFilter2(X, whiten_od);
    X = zscore(X, 0, 2);
    get_R_S;
  case 2
    % whiten the covariance in frequency domain
    [A2d, D] = ARregressionpd(getcovzpd(X, whiten_od), p);
    S = A2S(A2d, D, max(pow2ceil(8*whiten_od), 1024));
    S = StdWhiteS(S);
    R = S2cov(S, use_od);
    covz = R2covz(R);
  case 3
    % zeros the self coefficientss
    covz = getcovzpd(X, whiten_od);
    [A2d, D] = ARregressionpd(covz, p);
    for k = 1:p  % zeros the diag
      X(k,:) = filter([1 A2d(k,k:p:end)], [1], X(k,:));
    end
    clear A2d D
    get_R_S;
  case 4
    % get A from original signal, then whiten
    R_orig = getcovzpd(X, fit_od);
    [A2d, D] = ARregressionpd(R_orig, p);
    toc
    S = A2S(A2d, D, max(pow2ceil(8*whiten_od), 1024));
    S_orig = S;
    P_whiten_w = zeros(size(S));
    A_whiten_w = zeros(size(S));
    for k= 1:p
      P_whiten_w(k,k,:) = S2H1D(squeeze(S(k,k,:)));
      A_whiten_w(k,k,:) = 1 ./ P_whiten_w(k,k,:);
    end
%    A3d_w = fft( cat(3, eye(p), reshape(A2d, p,p,[])), size(S,3), 3);
%    A_w = mult3d(A3d_w, P_whiten_w);

    S = mult3d(A_whiten_w, S, HTR(A_whiten_w));
    for k=1:p
      S(k,k,:) = real(S(k,k,:));
    end
    R = S2cov(S, use_od);
%    covz = R2covz(R);
%    A3d = ifft(A_w, size(S,3), 3);

    [A2d, D] = ARregression(R);  % p=100, od=300, 132 sec

%    % verify that that A_w (or A0) is coef of whittened data
%    A1 = ARregression(R);
%    m = use_od;
%    figure(3); plot(1:m, real(A0(1,1,2:m+1)(:)), '-+', 1:m, A1(1,1:p:end), '-x')
%    figure(5); plot(1:m, real(A0(1,2,2:m+1)(:))' - A1(1,2:p:end), '-x')
    
  case 5
    % get A from original signal, then whiten
    covz_orig = getcovzpd(X, fit_od);  % p=100, 112 sec
    [A2d, D] = ARregressionpd(covz_orig, p);
    toc
    % p=100, 4 sec
    S_orig = A2S(A2d, D, max(pow2ceil(8*use_od), 1024));
    P_whiten_w = zeros(size(S_orig));
    A_whiten_w = zeros(size(S_orig));
    for k= 1:p
      P_whiten_w(k,k,:) = S2H1D(squeeze(S_orig(k,k,:)));
      A_whiten_w(k,k,:) = 1 ./ P_whiten_w(k,k,:);
    end
    A3d_w = fft( cat(3, eye(p), reshape(A2d, p,p,[])), size(S_orig,3), 3);
    A_w = mult3d(A3d_w, P_whiten_w);
    A3d = ifft(A_w, size(S_orig,3), 3);
    A2d = reshape(real(A3d(:,:,2:use_od+1)), p, []);  % overwrite A2d

    S = mult3d(A_whiten_w, S_orig, HTR(A_whiten_w));
    for k=1:p
      S(k,k,:) = real(S(k,k,:));
    end
    R = S2cov(S, use_od);
  otherwise
    get_R_S;
end
toc

%A0 = A2d;
%D0 = D;
%A1 = A2d;
%D1 = D;
%maxerr(A0 - A1)
%maxerr(D1 - D0)
%m = use_od;
%figure(4); plot(1:m, A0(1,2:p:end)); print -depsc2 a0.eps
%figure(4); plot(1:m, A1(1,2:p:end)); print -depsc2 a1.eps
%figure(5); plot(1:m, A0(1,2:p:end) - A1(1,2:p:end), '-x'); print -depsc2 b.eps
%return

R_orig = S2cov(S_orig, fit_od);
GC     = RGrangerTfast(R_orig);
pairGC = pairRGrangerT(R_orig);

tic
%[~, De, A] = RGrangerTLevinson(R);  % p=100,od=300, 52 sec
A = A2d;
De = D;
toc
tic
[~, ~, pairA] = pairRGrangerT(R);  % p=100,od=300, 37 sec, od=600, 147 sec
toc

end

net = 1*pm.net_adj;
fftlen = size(S,3);
m = use_od;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id1 = 1;
id2 = 40;

fprintf('net_connect (%d, %d) = %d\n', id1, id2, net(id1,id2));
fprintf('net_indirect(%d, %d) = %d\n', id1, id2, net(id1,:)*net(:,id2));
fprintf('net_common  (%d, %d) = %d\n', id1, id2, net(id1,:)*net(id2,:)');

gc_ans_joint = GC(id1, id2)
gc_ans_pair = pairGC(id1, id2)

id3 = 1:p;
id3([id1 id2]) = [];

Qw = zeros(size(S));
for k = 1:fftlen
    Qw(:,:,k) = inv(S(:,:,k));
end

Qyy_w = Qw(id2,id2,:);
Qyz_w = Qw(id2,id3,:);
Qzy_w = Qw(id3,id2,:);
Qzz_w = Qw(id3,id3,:);

figure(10);
plot(squeeze(S(id2,id2,:)));
ylabel('S(id2,id2)');

figure(11);
plot(real(squeeze(Qw(id2,id2,:))));
ylabel('Qw(id2,id2)');

A3d_w = fft( cat(3, eye(p), reshape(A, p,p,[])), fftlen, 3);
HTR = @(x) permute(conj(x), [2, 1, 3:ndims(x)]);

% full mimic approximation
A1c_w = permute(reshape(A(id1, :), p, []), [3 1 2]);
A12_w = fft(A1c_w(1,id2,:), fftlen, 3);
A13_w = fft(A1c_w(1,id3,:), fftlen, 3);
b12_w_app = A12_w - rdiv3d( A13_w, Qzz_w, Qzy_w);  % key
b12_t_app = real( ifft(b12_w_app, fftlen, 3) );
b12_t_app(floor((end+1)/2)+1:end) = 0;
b12_w_app = fft(b12_t_app, fftlen, 3);

gc_cond_a12_w_app_full = mean(real(A12_w ./ Qyy_w .* conj(A12_w))) / R(id1,id1)
gc_cond_a12_w_app = mean(real(A12_w .* conj(A12_w))) / R(id1,id1) * R(id2, id2)

Pw = zeros(2,2,size(S,3));
for k = 1:fftlen
    Pw(:,:,k) = inv(S([id1 id2],[id1 id2],k));
end

%gc_b12_t_app_full = mean(real(b12_w_app ./ (Qyy_w - rdiv3d(Qyz_w, Qzz_w, Qzy_w)) .* conj(b12_w_app))) / R(id1,id1)
gc_b12_t_app_full = mean(real(b12_w_app .* (S(id2,id2,:) - rdiv3d(S(id2,id1,:), S(id1,id1,:), S(id1,id2,:))) .* conj(b12_w_app))) / R(id1,id1)
gc_b12_t_app_full = mean(real(b12_w_app ./Pw(2,2,:) .* conj(b12_w_app))) / R(id1,id1)

aa=1./Qyy_w;
bb=1./(Qyy_w - rdiv3d(Qyz_w, Qzz_w, Qzy_w));
cc=(S(id2,id2,:) - rdiv3d(S(id2,id1,:), S(id1,id1,:), S(id1,id2,:)));
%figure(9); plot(real(cc(:)))

gc_b12_w_app = mean(b12_w_app .* conj(b12_w_app)) / R(id1, id1) * R(id2, id2)
gc_b12_t_app = sum(b12_t_app(1:m).^2) / R(id1, id1) * R(id2, id2)

%Qzz_w_app = S(id3,id3,:) - rdiv3d(S(id3,[id1 id2],:), S([id1 id2],[id1 id2],:), S([id1 id2], id3,:)); % - rdiv3d(eye(p-2),Qw(id3,id3,:))
Qzz_w_app = ...
  rdiv3d( HTR(A3d_w(id1,id3,:)), De(id1,id1), A3d_w(id1,id3,:)) + ...
  rdiv3d( HTR(A3d_w(id2,id3,:)), De(id2,id2), A3d_w(id2,id3,:)) + ...
  rdiv3d( HTR(A3d_w(id3,id3,:)), De(id3,id3), A3d_w(id3,id3,:));

%Qzz_w_app = ...
%  rdiv3d( HTR(A3d_w(3:end,3:end,:)), De(3:end,3:end), A3d_w(3:end,3:end,:));

b12_w_app_v4 = A12_w - rdiv3d( A13_w, Qzz_w_app, Qzy_w);  % key
b12_t_app_v4 = real( ifft(b12_w_app_v4, fftlen, 3) );
b12_t_app_v4(floor((end+1)/2)+1:end) = 0;
b12_w_app_v4 = fft(b12_t_app_v4, fftlen, 3);

gc_b12_t_app_v4 = sum(b12_t_app_v4(1:m).^2) / R(id1, id1) * R(id2, id2)

figure(3);
plot(1:m, pairA(id1,id2:p:end), '-x',...
     1:m, squeeze(b12_t_app(1:m)), '-+',...
     1:m, squeeze(b12_t_app_v4(1:m)), '-o',...
     1:m, A(id1,id2:p:end), '-.');
legend('cal', 'app full', 'app acoef', 'cond')
print('-depsc2', 'e.eps');

diff_pairA_A = pairA(id1,id2:p:end) - A(id1,id2:p:end);
diff_b12_t_app_A = b12_t_app(:,1:m) - A(id1,id2:p:end);
diff_b12_t_app_v4_A = b12_t_app_v4(:,1:m) - A(id1,id2:p:end);

figure(4);
plot(1:m, diff_pairA_A, '-x',...
     1:m, diff_b12_t_app_A, '-+',...
     1:m, diff_b12_t_app_v4_A, '-o')
legend('pairA - A', 'app full - A', 'app Q - A')

% vim: set ts=2 sw=2 ss=2
