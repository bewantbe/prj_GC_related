% compare pairwise GC and approximate pairwise GC
clear

simu_time = 1e6;
p = 10;
n_indirect = 1;
sparseness = round(sqrt(p*n_indirect))/p;


net_param = [];
net_param.generator  = 'gen_sparse_mt19937';
net_param.p          = p;
net_param.sparseness = sparseness;
net_param.seed       = 4563;
net_param.software   = 'MT19937';

gen_network = @(np) eval(sprintf('%s(np);', np.generator));

pm = [];
pm.neuron_model = 'HH3_gcc49_westmere2_nogui';
pm.net_param = net_param;
pm.net  = gen_network(net_param);
%pm.net  = 'net_100_0X3CC7CFD0';
pm.nI   = round(0.2*net_param.p);
pm.nE   = net_param.p - pm.nI;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.10;
pm.scii = 0.10;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = simu_time;
pm.stv  = 0.5;
%pm.extra_cmd = '-q';

use_od = 40;

[X, ISI, ras, pm] = gen_HH(pm, 'ext_T', 'worker/data/');

whiten_od = 40;
use_od = 40;

%tic;
%wX = WhiteningFilter(X, whiten_od);
%toc
%wX = zscore(wX, 0, 2);

% whiten the covariance in frequency domain
fftlen = 1024;
tic;
covz = getcovzpd(X, whiten_od);
toc
[A2d, D] = ARregressionpd(covz, p);
S = A2S(A2d, D, fftlen);
S = StdWhiteS(S);
R = S2cov(S, use_od);
covz = R2covz(R);

tic;
[GC, De, wA] = RGrangerTfast(R);
toc;

tic;
[pairGC, ~, pairwA] = pairRGrangerT(R);
toc;

%mean(GC(:))
%1.2582e-04

return;


ft_A = fft( cat(3, eye(p), reshape(wA, p,p,[])), fftlen, 3);
HTR = @(x) permute(conj(x), [2, 1, 3:ndims(x)]);

zeroA = ft_A;
for k = 1:p  % zeros the diag
  zeroA(k+p*(k-1):p*p:end) = 0;
end

ft_pairA_app = zeroA - mult3d(zeroA, zeroA + HTR(zeroA));
pairA_app = real(ifft(ft_pairA_app, fftlen, 3));
pairA_app = pairA_app(:,:,2:use_od+1);

figure(2);
plot(1:m, pairwA(1,2:p:end), '-x', 1:m, squeeze(pairA_app(1,2,:))', '-o');
legend('cal', 'approx')
print('-depsc2', 'b.eps');


%ft_b12_app_expr3 = -ft_A(1,2,:) + mult3d(ft_A(1,3:end,:), ft_A(3:end,2,:) + HTR(ft_A(2,3:end,:)));

%ift_b12_app_expr3 = real(ifft(ft_b12_app_expr3(:), fftlen))';
%m = use_od;
%b12 = -squeeze(pairwA(1,2:p:end)');
%figure(7); plot(1:m, b12, '-x', 1:m, ift_b12_app_expr3(2:m+1), '-o' );
%print('-depsc2', 'c.eps');


% vim: set ts=4 sw=4 ss=4
