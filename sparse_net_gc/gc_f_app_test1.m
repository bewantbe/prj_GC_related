

f_mean_sqr = @(c) real(mean( c.*conj(c), 3 ));

%[p, len] = size(X);
%covz = getcovzpd(X, m);
%[A2d, D] = ARregressionpd(covz, p);


%D   = diag([0.9 1.0 0.8]);
%A2d = [-0.8   0.0   0.0  0.5 -0.07   0.0;
        %0.05 -0.9   0.0  0.0  0.8    0.0;
        %0.0   0.04 -0.5  0.0  0.03   0.2];
A2d = -[0 0 0.1; 0 0 -5; 0 0 0.95];
D   = diag([1 1 1]);

p = size(A2d, 1);
fftlen = 1024;
S = A2S(A2d, D, fftlen);
S = StdWhiteS(S);
od = 90;
R = S2cov(S, od);
[A2d, D] = ARregression(R);

gc = RGrangerT(R)

A = cat(3, eye(p), reshape(A2d, p,p,[]));
ft_A = fft(A, fftlen, 3);

iS = zeros(size(S));
iSyy = zeros(size(S));
for k = 1 : fftlen
  iS(:,:,k) = inv(S(:,:,k));
  iSyy(:,:,k) = repmat( diag(iS(:,:,k))', p, 1);
end

ft_gc_1 = real( mean( ft_A ./ iSyy .* conj(ft_A) ,3) )

