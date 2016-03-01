%

if ~exist('ed', 'var') || isempty(ed) || ~ed
ed = true;

%gen_data_n10_c1;
gen_data_n40_c1;
%gen_data_n100_c1;

[p len] = size(X);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% preprocessing and get spectrum, R and covz
use_od = 80;
whiten_od = 80;

mode_preprocessing = 1;
switch mode_preprocessing
  case 1
    X = WhiteningFilter2(X, whiten_od);
    X = zscore(X, 0, 2);
    get_R_S;
  case 2
    % whiten the covariance in frequency domain
    covz = getcovzpd(X, whiten_od);
    [A2d, D] = ARregressionpd(covz, p);
    S = A2S(A2d, D, max(2^ceil(log2(8*whiten_od)), 1024));
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
end


tic;
[GC, De, A] = RGrangerTfast(R);
toc;

tic;
[pairGC, ~, pairA] = pairRGrangerT(R);
toc;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id1 = 1;
id2 = 2;

gc_ans_joint = GC(id1, id2)
gc_ans_pair = pairGC(id1, id2)

id3 = 1:p;
id3([id1 id2]) = [];

fftlen = size(S,3);
m = use_od;

Qw = zeros(size(S));
for k = 1:fftlen
    Qw(:,:,k) = inv(S(:,:,k));
end

Qyy_w = Qw(id2,id2,:);
Qyz_w = Qw(id2,id3,:);
Qzy_w = Qw(id3,id2,:);
Qzz_w = Qw(id3,id3,:);

A3d_w = fft( cat(3, eye(p), reshape(A, p,p,[])), fftlen, 3);
HTR = @(x) permute(conj(x), [2, 1, 3:ndims(x)]);

A1c_w = permute(reshape(A(id1, :), p, []), [3 1 2]);
A12_w = fft(A1c_w(1,id2,:), fftlen, 3);
A13_w = fft(A1c_w(1,id3,:), fftlen, 3);
b12_w_app = A12_w - rdiv3d( A13_w, Qzz_w, Qzy_w);  % key
b12_t_app = real( ifft(b12_w_app, fftlen, 3) );
b12_t_app(floor((end+1)/2)+1:end) = 0;
b12_w_app = fft(b12_t_app, fftlen, 3);

gc_b12_w_app = mean(b12_w_app .* conj(b12_w_app))
gc_b12_t_app_full = mean(b12_w_app ./ (Qyy_w - rdiv3d(Qyz_w, Qzz_w, Qzy_w)) .* conj(b12_w_app)) / R(id2,id2)

gc_b12_t_app = sum(b12_t_app(1:m).^2)

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

gc_b12_t_app_v4 = sum(b12_t_app_v4(1:m).^2)

figure(3);
plot(1:m, pairA(id1,id2:p:end), '-x',...
     1:m, squeeze(b12_t_app(1:m)), '-+',...
     1:m, squeeze(b12_t_app_v4(1:m)), '-o',...
     1:m, A(id1,id2:p:end), '-.');
legend('cal', 'app full', 'app acoef', 'cond')
print('-depsc2', 'e.eps');

diff_pairA_A = pairA(id1,id2:p:end) - A(id1,id2:p:end);
diff_b12_t_app_A = squeeze(b12_t_app(1:m))' - A(id1,id2:p:end);
diff_b12_t_app_v4_A = squeeze(b12_t_app_v4(1:m))' - A(id1,id2:p:end);

figure(4);
plot(1:m, diff_pairA_A, '-x',...
     1:m, diff_b12_t_app_A, '-+',...
     1:m, diff_b12_t_app_v4_A, '-o')
legend('pairA - A', 'app full - A', 'app Q - A')

% vim: set ts=2 sw=2 ss=2
