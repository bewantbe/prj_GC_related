% compare pairwise GC and approximate pairwise GC
clear

%{
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
%}

simu_time = 1e6;
p = 100;

pm = [];
pm.neuron_model = 'HH3_gcc49_westmere2_nogui';
pm.net  = 'net_100_0X3CC7CFD0';


pm.nI   = round(0.2*p);
pm.nE   = p - pm.nI;
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

return;

whiten_od = 80;
use_od = 80;

tic;
X = WhiteningFilter(X, whiten_od);
toc
X = zscore(X, 0, 2);

%covz = getcovzpd(X, whiten_od);
%[A2d, D] = ARregressionpd(covz, p);
%for k = 1:p  % zeros the diag
%  X(k,:) = filter([1 A2d(k,k:p:end)], [1], X(k,:));
%end


% whiten the covariance in frequency domain
fftlen = 1024;
tic;
covz = getcovzpd(X, whiten_od);
toc
tic
[A2d, D] = ARregressionpd(covz, p);
S = A2S(A2d, D, fftlen);
%S = StdWhiteS(S);
R = S2cov(S, use_od);
covz = R2covz(R);
toc

tic;
[GC, De, wA] = RGrangerTfast(R);
toc;
A3d = reshape(wA, p, p, []);

tic;
[pairGC, ~, pairwA] = pairRGrangerT(R);
toc;

%mean(GC(:))
%1.2582e-04

covz_orig = covz;
m = use_od;
are_you_joking = true;
len = round(pm.t/pm.stv);
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

m = use_od;

%id1 = 25;
%id2 = 54;

%figure(2);
%plot(1:m, pairwA(id1,id2:p:end), '-x', 1:m, squeeze(pairA_app(id1,id2,:))', '-o');
%legend('cal', 'approx')
%print('-depsc2', 'b.eps');


%%ft_b12_app_expr3 = -ft_A(1,2,:) + mult3d(ft_A(1,3:end,:), ft_A(3:end,2,:) + HTR(ft_A(2,3:end,:)));

%%ift_b12_app_expr3 = real(ifft(ft_b12_app_expr3(:), fftlen))';
%%m = use_od;
%%b12 = -squeeze(pairwA(1,2:p:end)');
%%figure(7); plot(1:m, b12, '-x', 1:m, ift_b12_app_expr3(2:m+1), '-o' );
%%print('-depsc2', 'c.eps');

%% full mimic

%Qw = zeros(size(S));
%for k = 1:fftlen
%    Qw(:,:,k) = inv(S(:,:,k));
%end

%diagQwinv = zeros(size(S));
%for k = 1:fftlen
%    diagQwinv(:,:,k) = inv(diag(diag(Qw(:,:,k))));
%end
%zeroQw = Qw;
%for k = 1:p  % zeros the diag
%  zeroQ(k+p*(k-1):p*p:end) = 0;
%end

%ft_b_app_full = zeroA - mult3d(zeroA, diagQwinv, zeroQw);
%b_app_full = real(ifft(ft_b_app_full, fftlen, 3));
%b_app_full = b_app_full(:,:,2:use_od+1);

%figure(2);
%plot(1:m, pairwA(id1,id2:p:end), '-x',...
%     1:m, squeeze(pairA_app(id1,id2,:))', '-o',...
%     1:m, squeeze(b_app_full(id1,id2,:))', '-+');
%legend('cal', 'approx', 'app full')
%print('-depsc2', 'd.eps');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
id1 = 1;
id2 = 2;

Qw = zeros(size(S));
for k = 1:fftlen
    Qw(:,:,k) = inv(S(:,:,k));
end

id3 = 1:p;
id3([id1 id2]) = [];
ft_Qyy_a = Qw(id2,id2,:);
ft_Qyz_a = Qw(id2,id3,:);
ft_Qzy_a = Qw(id3,id2,:);
ft_Qzz_a = Qw(id3,id3,:);

ft_A = fft( cat(3, eye(p), reshape(wA, p,p,[])), fftlen, 3);
HTR = @(x) permute(conj(x), [2, 1, 3:ndims(x)]);

a1_3d = permute(reshape(wA(id1, :), p, []), [3 1 2]);
ft_a12 = fft(a1_3d(1,id2,:), fftlen, 3);
ft_a13 = fft(a1_3d(1,id3,:), fftlen, 3);
ft_b12_app = ft_a12 - rdiv3d( ft_a13, ft_Qzz_a, ft_Qzy_a);
ift_b12_app = real( ifft(ft_b12_app, fftlen) );
ift_b12_app(floor((end+1)/2)+1:end) = 0;
ft_b12_app = fft(ift_b12_app);

%ft_b12_app = squeeze(ft_b12_app)';
%gc_ift_b12_app_full = sum(ft_b12_app .* conj(ft_b12_app))
gc_ift_b12_app_full = sum(ft_b12_app ./ (ft_Qyy_a - rdiv3d(ft_Qyz_a, ft_Qzz_a, ft_Qzy_a)) .* conj(ft_b12_app)) / R(id2,id2)

gc_ift_b12_app = ift_b12_app(1:m) * ift_b12_app(1:m)'

%ft_Qzz_a_app = S(id3,id3,:) - rdiv3d(S(id3,[id1 id2],:), S([id1 id2],[id1 id2],:), S([id1 id2], id3,:)); % - rdiv3d(eye(p-2),Qw(id3,id3,:))
ft_Qzz_a_app = ...
  rdiv3d( HTR(ft_A(id1,id3,:)), De(1,1), ft_A(1,3:end,:)) + ...
  rdiv3d( HTR(ft_A(id2,id3,:)), De(2,2), ft_A(2,3:end,:)) + ...
  rdiv3d( HTR(ft_A(3:end,3:end,:)), De(3:end,3:end), ft_A(3:end,3:end,:));

%ft_Qzz_a_app = ...
%  rdiv3d( HTR(ft_A(3:end,3:end,:)), De(3:end,3:end), ft_A(3:end,3:end,:));

ft_b12_app_v4 = ft_a12 - rdiv3d( ft_a13, ft_Qzz_a_app, ft_Qzy_a);
ift_b12_app_v4 = real( ifft(ft_b12_app_v4, fftlen) );
ift_b12_app_v4 = squeeze(ift_b12_app_v4(1:m))';
gc_ift_b12_app_v4 = ift_b12_app_v4 * ift_b12_app_v4'

figure(3);
plot(1:m, pairwA(id1,id2:p:end), '-x',...
     1:m, squeeze(ift_b12_app(1:m)), '-+',...
     1:m, ift_b12_app_v4(1:m), '-o',...
     1:m, wA(id1,id2:p:end), '-.');
legend('cal', 'app full', 'app acoef', 'cond')
print('-depsc2', 'e.eps');

ft_b12_app_v4 = - rdiv3d( ft_a13, ft_Qzz_a_app, ft_Qzy_a);
ift_b12_app_v4 = real( ifft(ft_b12_app_v4, fftlen) );
ift_b12_app_v4 = squeeze(ift_b12_app_v4(1:2*m))';

figure(4);
plot(1:m, pairwA(id1,id2:p:end) - wA(id1,id2:p:end), '-x',...
     1:m, squeeze(ift_b12_app(1:m))' - wA(id1,id2:p:end), '-+',...
     1:2*m, ift_b12_app_v4(1:2*m), '-o')


% vim: set ts=4 sw=4 ss=4
