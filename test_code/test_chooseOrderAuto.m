%
tocs = @(st) fprintf('t =%7.3fs : %s\n', toc(), st);

b_residual_test = false;
b_correctness_test = true;

test_type = 'linear';
%test_type = 'neuron';
test_no = 6;

if b_residual_test
  X=randn(10,1e5);

  max_od = 50;

  tic;
  [~,~,det_de] = chooseOrderAuto(X, [], max_od);
  t=toc

  tic;
  R = getcovpd(X, max_od);
  [af, s_de] = BlockLevinson(R);
  t=toc
  ans_lndet_de = [];
  for k=1:size(s_de,3)
    ans_lndet_de(k) = det(s_de(:,:,k));
  end

  norm(det_de-ans_lndet_de)

  figure(2);
  %plot(det_de-ans_lndet_de);
  plot(det_de);
end  % if b_residual_test


if b_correctness_test
  len = 1e3;
  max_od = 100;

  tic;
  switch test_type

    case 'linear'
      switch test_no
        case 1
          A = [-0.9 ,  0.0, 0.5, 0.0;
               -0.16, -0.8, 0.2, 0.5];
          De = [1.0, 0.4; 0.4, 0.7];
        case 2
          A = [-0.8  0.0 -0.4  0.5 -0.2  0.0;
                0.0 -0.9  0.0  0.0  0.8  0.0;
                0.0 -0.5 -0.5  0.0  0.0  0.2];
          De = diag([0.3 1.0 0.2]);
        case 3
          s2 = sqrt(2);
          A = zeros(5, 5*90);
          A(1,1) =-0.95*s2;  A(1,6) = 0.9025;
          A(2,6) =-0.5;
          A(3,11)= 0.4;
          A(4,6) = 0.5;      A(4,4) =-0.25*s2;  A(4,5) =-0.25*s2;
          A(5,4) = 0.25*s2;  A(5,5) =-0.25*s2;
          De = diag([0.6 0.5 0.3 0.3 0.6]);
        case 4
          s2 = sqrt(2);
          A = zeros(5, 5*50);
          A(1,1) =-0.95*s2;  A(1,6) = 0.9025;
          A(2,6) =-0.5;
          A(3,11)= 0.4;
          A(4,6) = 0.5;      A(4,4) =-0.25*s2;  A(4,5) =-0.25*s2;
          A(5,4) = 0.25*s2;  A(5,5) =-0.25*s2;
          De = diag([0.6 0.5 0.3 0.3 0.6]);
          A(5, 5*50) = 0.1;
        case 5
          A = [-0.9 ,  0.0, 0.5, 0.0;
               -0.16, -0.8, 0.2, 0.5];
          De = [1.0, 0.4; 0.4, 0.7];
          p = size(A,1);
          [G, de] = gen_hfreq_coef(0.9, 0.05, 4);
          B = zeros(length(G),p,p);
          for k=1:p
            B(:,k,k) = G;
          end
          B = reshape(permute(B, [2,3,1]), p, []);
          A = conv1mat(A, B);
        case 6
          A = [-0.9 ,  0.0, 0.5, 0.0;
               -0.16, -0.8, 0.2, 0.5];
          De = [1.0, 0.4; 0.4, 0.7];
          p = size(A,1);
          [G, de] = gen_hfreq_coef(0.9, 0.05, 6);
          B = zeros(length(G),p,p);
          for k=1:p
            B(:,k,k) = G;
          end
          B = reshape(permute(B, [2,3,1]), p, []);
          A = conv1mat(A, B);
        otherwise
          error('no this case.');
      end
      X = gendata_linear(A, De, len);

    case 'neuron'
      switch test_no
        case 1
          stv = 0.5;
          [X, ISI] = gendata_neu('net_2_2', 0.01, 1, 0.012, len*stv, stv, '-dt 0.25 --RC-filter -q');
        case 2
          stv = 0.5;
          [X, ISI] = gendata_neu('net_2_2', 0.01, 16, 0.00125, len*stv, stv, '-dt 0.25 --RC-filter -q');
        otherwise
          error('no this case');
      end
      ISI

    otherwise
      error('no this type of test');

  end
  p = size(X,1);
  tocs('generate data');

  tic;
  [bicod_auto, s_xic_val_auto, s_lndet_de_auto] = chooseOrderAuto(X, 'BIC');
  bicod_auto
  tocs('chooseOrderAuto(X, ''BIC'')');

  tic;
  [bicod, s_xic_val, s_lndet_de] = chooseOrderAuto(X, 'BIC', max_od);
  bicod
  tocs('chooseOrderAuto(X, ''BIC'', max_od)');

  tic;
  [bicod_pd, s_xic_val_pd, s_lndet_de_pd] = chooseOrderAuto(X, 'BIC', -max_od);
  bicod_pd
  tocs('chooseOrderAuto(X, ''BIC'', -max_od)');

  %bicod_ans = chooseOrder(X,'BIC')

  tic;
  s_od = 1:max_od;
  %[oGC, oDe, R] = AnalyseSeries(X, s_od);
  [oGC, oDe, R] = AnalyseSeriesFast(X, s_od);
  [aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
  bic_od
  tocs('AnalyseSeriesFast(s_od, oGC, oDe, len)');

  rg = 1:length(s_xic_val)-1;
  %figure(1);
  %plot(rg, s_xic_val(rg));
  %figure(2);
  %plot(rg, oBIC(rg));
  %figure(3);
  %plot(s_xic_val_pd);

  %figure(4);
  %plot(1:length(s_lndet_de), s_lndet_de, 1:length(s_lndet_de_pd), s_lndet_de_pd);
  figure(5);
  %plot(1:length(s_lndet_de_auto), s_lndet_de_auto, 1:length(s_lndet_de_pd), s_lndet_de_pd);
  plot(1:length(s_lndet_de_auto), s_lndet_de_auto-s_lndet_de_pd(1:length(s_lndet_de_auto)));
  fprintf('Ave order diff: %g\n', exp((s_lndet_de_pd(1)-s_lndet_de_pd(bicod_pd))/p));
  norm(s_xic_val(rg)-oBIC(bicod_pd))

end  % if correctness test
