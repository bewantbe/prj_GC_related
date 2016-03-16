% test approximation of toeplitz matrix operations

pow2ceil = @(x) 2^ceil(log2(x));
maxerr = @(x) max(abs(x(:)));

if ~exist('ed', 'var') || isempty(ed) || ~ed
  tic;
  ed = true;

  %gen_data_n10_c1;
  gen_data_n40_c1;  % 1 40, aic_od=31
  %gen_data_n100_c1;  % 32  32

  whiten_od = 50;
  use_od = 200;

  [A2d, D] = ARregressionpd(getcovzpd(X, whiten_od), p);
  S = A2S(A2d, D, max(pow2ceil(8*whiten_od), 1024));
  S = StdWhiteS(S);
  R = S2cov(S, use_od);
  covz = R2covz(R);

  toc;
end

bigR = covz;
Q = inv(bigR);
tQ = R2covz(S2cov(rdiv3d(eye(p), S), use_od));

figure(1);
plot(bigR(floor(end/2), :));
figure(2);
imagesc(R(:,p+1:end));
colorbar();

Id = eye(p*(use_od+1));
aux_K = Id - tQ * bigR;

Q_app_0 = tQ;
Q_app_1 = (Id + aux_K) * tQ;
Q_app_2 = (Id + aux_K + aux_K^2) * tQ;

Qexact = (Id - aux_K) \ tQ;

figure(3);
imagesc( -aux_K((1:60),(1:60)) );
%imagesc( bigR(200+(1:60),200+(1:60)) );
colorbar();
caxis([-1,1]*1e-1);
title('aux\_K');

maxerr(Qexact - Q)
maxerr(Q_app_0 - Q)
maxerr(Q_app_1 - Q)
maxerr(Q_app_2 - Q)

return

id1=1;
id2=1;

%bigR = covz(id1:p:end, id2:p:end);
%Q = inv(bigR);
%tQ = R2covz(S2cov(rdiv3d(eye(p), S(id1,id2,:)), use_od));

%id_mat = Q*bigR;  % check the answer

aux_K = eye(use_od+1) - tQ * bigR;

Q_app_0 = tQ;
%Q_app_1 = 2*Q_app_0 - Q_app_0 * bigR * Q_app_0;
%Q_app_1 = (eye(use_od+1) + aux_K + aux_K^2) * tQ;
Q_app_1 = (eye(use_od+1) + aux_K) * tQ;
Q_app_1 = -aux_K + tQ;
%Q_app_1 = (eye(use_od+1) - aux_K) \ tQ;

id_mat_app0 = Q_app_0 * bigR;  % app id
id_mat_app1 = Q_app_1 * bigR;  % app id

[u,s,v] = svd(bigR);

figure(10); semilogy(svd(id_mat_app0 - eye(use_od+1)));
figure(11); semilogy(svd(tQ - Q));

figure(1);
imagesc( -aux_K(1:60,1:60) );
colorbar();
caxis([-1,1]*1e-1);
title('aux\_K');

figure(2);
imagesc( (id_mat_app0 - eye(use_od+1))(1:60,1:60) );
colorbar();
caxis([-1,1]*1e-1);
title('diff app0');

figure(3);
imagesc( (id_mat_app1 - eye(use_od+1))(1:60,1:60) );
colorbar();
caxis([-1,1]*1e-1);
title('diff app1');

rg1 = 1:200;
rg2 = (1:200)+200;
rg3 = (1:200)+400;
ta_0  = tQ(rg1, rg1);
ta_p1 = tQ(rg1, rg2);
ta_n1 = tQ(rg2, rg1);
tb_0  = bigR(rg1, rg1);
tb_p1 = bigR(rg1, rg2);
tb_n1 = bigR(rg2, rg1);

figure(4);
imagesc( - ta_n1 * tb_p1 );
%imagesc( ta_0*tb_0 + ta_p1*tb_n1 - eye(length(rg1)) );
imagesc( (- ta_n1 * tb_p1)(1:60,1:60) );
colorbar();
caxis([-1,1]*1e-1);

figure(5);
imagesc( (- ta_n1 * tb_p1)(1:60,1:60) - (id_mat_app0 - eye(use_od+1))(1:60,1:60) );
%imagesc( ta_n1*tb_p1 + ta_0*tb_0 + ta_p1*tb_n1 - eye(length(rg1)) );
colorbar();
caxis([-1,1]*1e-14);


% vim: set ts=2 sw=2 ss=2
