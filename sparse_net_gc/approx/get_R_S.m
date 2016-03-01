% input: X, use_od, 

covz = getcovzpd(X, use_od);
[A2d, D] = ARregressionpd(covz, size(X, 1));
S = A2S(A2d, D, max(2^ceil(log2(8*use_od)), 1024));
clear A2d D

R = S2cov(S, use_od);
covz = R2covz(R);

