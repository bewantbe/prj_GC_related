
p = 10;
len = 1e5;
rand('state',1);
X = rand(p,len);

od = 100;
tic
covz = getcovzpd(X, od);
toc

tic
R = getcovpd(X, od);
toc
X_no_mean = bsxfun(@minus, X, mean(X,2));
tic
covz2 = getcovzFromRpd(X_no_mean, R, od);
toc

max(abs(covz(:)-covz2(:)))
mean(abs(covz(:)-covz2(:)))
max(abs(covz(:)))
%pcolor(abs(covz-covz2))
%colorbar();
