% run('~/matcode/GC_clean/.octaverc');
tocs = @(st) fprintf('t =%7.3fs : %s\n', toc(), st);

len = 1e5;
p = 2;
%X = randn(p, len);
if p==2
    A = [-0.9 ,  0.0, 0.5, 0.0;
         -0.16, -0.8, 0.2, 0.5];
    De = [1.0, 0.4; 0.4, 0.7];
end

% increase condition number of AR model
[G, de] = gen_hfreq_coef(0.9, 0.05, 4);
%plot(real(squeeze(A2S(G, de, 1024)))); legend(['Order ',num2str(length(G))]);
B = zeros(length(G),p,p);
for k=1:p
  B(:,k,k) = G;
end
B = reshape(permute(B, [2,3,1]), p, []);
A = conv1mat(A, B);

len_ext = 1e4;
X = gendata_linear(A, De, len+len_ext);
X(:,1:len_ext) = [];

% increase condition number at time t
%num_cond = 10^5;
%[Q,r] = qr(randn(p));
%v = logspace(-log10(num_cond)/2, log10(num_cond)/2, p);
%M = Q*diag(sqrt(v));
%X = M*X;

od = 20;

pos_nGrangerT2(X,od,1);

tic;
gc1 = nGrangerT(X,od);
tocs('nGrangerT');

tic;
gc2 = pos_nGrangerT2(X,od);
tocs('pos_nGrangerT2');

tic;
gc3 = pos_nGrangerT_qr(X,od);
tocs('pos_nGrangerT_qr');

tic;
gc4 = pos_nGrangerT(X,od);
tocs('pos_nGrangerT');

tic;
gc5 = RGrangerT(getcov_circle(X,od));
tocs('RGrangerT(getcov_circle');

tic;
gc6 = AnalyseSeriesFast(X,od);
tocs('AnalyseSeriesFast');


max(abs(gc1-gc2)(:))
max(abs(gc3-gc2)(:))
max(abs(gc4-gc2)(:))
max(abs(gc5-gc2)(:))
max(abs(gc6-gc2)(:))
