% "an example where ugpdc3 is 6times greater than GC"

A2d = -[0 0 0.1; 0 0 -5; 0 0 0.95];
D   = diag([1 1 1]);
ARroots(A2d);

od = 200;
fftlen = 8192;
S = A2S(A2d, D, fftlen);
R = S2cov(S, od);

GC = RGrangerT(R)

ugpdc = uGPDC_A(A2d, D, fftlen);
ugpdc3 = real(mean(log(1+ugpdc.*conj(ugpdc)),3));ugpdc3 = ugpdc3 - diag(diag(ugpdc3))

