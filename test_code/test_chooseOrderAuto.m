%

X=randn(10,1e5);

tic;
det_de = chooseOrderAuto(X);
t=toc

m = 50;
tic;
R = getcovpd(X, m);
[af, s_de] = BlockLevinson(R);
t=toc
ans_det_de = [];
for k=1:size(s_de,3)
  ans_det_de(k) = det(s_de(:,:,k));
end

norm(det_de-ans_det_de)

figure(2);
plot(det_de-ans_det_de);

