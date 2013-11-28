
len = 1e5;
X=randn(10,1e5);
p = size(X,1);

od = 1;
covz = getcovzpd(X, od);
[A1, De1] = ARregressionpd(covz, p);

[~, De0, A0] = pos_nGrangerT2(X, od);

norm(A1-A0)
norm(De1-De0)
