%

if ~exist('are_you_joking', 'var')
are_you_joking = true;

  model_id = 2;
  switch model_id
  case 1
    clear('pm');
    pm.neuron_model = 'LIF';
    pm.net  = 'net_3_06';
    pm.scee = 0.01;
    pm.pr   = 1.0;
    pm.ps   = 0.012;
    pm.t    = 1e7;
    pm.stv  = 0.5;
    [X, ISI, ras] = gen_HH(pm);

    [p, len] = size(X);

    b_use_spike_train = false;
    % Convert to spike train if requested
    if b_use_spike_train
      clear('X');
      X = SpikeTrains(ras, p, len, pm.stv);
    end

    aic_od = chooseOrderAuto(X,'AIC');
    bic_od = chooseOrderAuto(X,'BIC');
    srd = WhiteningFilter(X, aic_od);

    fprintf('X: aic od = %d, bic_od = %d\n', aic_od, bic_od);

    % the fitting order used to calculate GC
    use_od = aic_od;
    m = use_od;

    %%%%%%%%%%%%%%%%%%%%%%%
    % Calculate GC

    % by X
    GC_X   = pos_nGrangerT2(X, use_od)
    clear('X');

    % by srd
    GC_srd_whole = pos_nGrangerT2(srd, use_od)
    covz = getcovz(srd, use_od);
    clear('srd');

    R = covz(1:p, 1:end);

  case 2
    D = diag([0.9 1.0 0.8]);
    A = [-0.8   0.0   0.0  0.5 -0.02   0.0;
          0.05 -0.9   0.0  0.0  0.8    0.0;
          0.0   0.02 -0.5  0.0  0.03   0.2];
    %A = [-0.8   0.0   0.0  0.5 -0.07   0.0;
          %0.05 -0.9   0.0  0.0  0.8    0.0;
          %0.0   0.04 -0.5  0.0  0.03   0.2];
    fftlen = 2048;
    S = A2S(A, D, fftlen);
    S = StdWhiteS(S);
    od = 300;
    R = S2cov(S, od);
    covz = R2covz(R);

    p = size(S, 1);
    len = 1e9;
    use_od = od;
    m = use_od;

  endswitch

  % Make S^(xx) identical matrix
  % i.e. Assume `srd' is purely white for each variables
  id_p   = 1 : p : (p*(m+1));
  id_p_2 = 1 : p*p*(m+1)+p : p*p*(m+1)*(m+1);
  for k = 1 : p
      covz(id_p,id_p) = diag(covz(id_p_2));
      id_p = id_p + 1;
      id_p_2 = id_p_2 + p*(m+1) + 1;
  end
  covz_orig = covz;  % save a copy

else
  covz = covz_orig;  % load copy
end

% Name for coefficients
%     [Xt Yt Zt]' = A * eps[x,y,z]t
% B * [Xt Yt Zt]' =     eps[x,y,z]t
%     [Xt    Zt]' = C * eps[x,  z]t
% D * [Xt    Zt]' =     eps[x,  z]t
%     [Xt Yt   ]' = E * eps[x,y  ]t
% F * [Xt Yt   ]' =     eps[x,y  ]t

[GC_srd_covz, Deps] = pos_nGrangerT2RZ(covz, p);
if (p < 6)
  GC_srd_covz
end

GC_srd_pairs = pairRGrangerT(R);
if (p < 6)
  GC_srd_pairs
end
% Permute the variables in covz
% e.g. to get y->z, set permvec = [3 2 1]
%permvec = [3 2 1];              % variable index after permutation
%permvec = [2 3 1];              % variable index after permutation
permvec = [3 1 2];              % variable index after permutation
%permvec = [1 3 2];              % variable index after permutation
%permvec = [1 2 3];              % variable index after permutation
%permvec = [2 1 3];              % variable index after permutation
test_gc_app3var_v2_preparevars;

% iterative
B2 = eye(size(eS2)) - eS2;
B3 = eye(size(eS3)) - eS3;

fprintf('norm of B2 = %f\n', norm(B2));
fprintf('norm of B3 = %f\n', norm(B3));

GC_fomula = log(...
    (1 - esv2 / eS2 * esv2')/...
    (1 - esv3 / eS3 * esv3'))

quotient_core =...
    1 - (1 - esv3 / eS3 * esv3') /...
        (1 - esv2 / eS2 * esv2')
var_reduction =...
    esv3 / eS3 * esv3' - esv2 / eS2 * esv2'

quotient_core_expension_od4_v1 =...
    1 - (1 - esv3 * (B3^0 + B3^1 + B3^2 + B3^3 + B3^4) * esv3') /...
        (1 - esv2 * (B2^0 + B2^1 + B2^2 + B2^3 + B2^4) * esv2')

quotient_core_expension_od2_v1 =...
    1 - (1 - esv3 * (B3^0 + B3^1 + B3^2) * esv3') /...
        (1 - esv2 * (B2^0 + B2^1 + B2^2) * esv2')
quotient_core_expension_od1_v1 =...
    1 - (1 - esv3 * (B3^0 + B3^1) * esv3') /...
        (1 - esv2 * B2^0 * esv2')
quotient_core_expension_od1_v2 =...
    v1O2*v1O2' + esv3 * B3 * esv3'

GC_approx_od2 = v1O2*v1O2' - 2*v1O2 * V23 * v1O3'
GC_approx_od2_wrong = v1O2*v1O2' - v1O2 * V23 * v1O3'

GC_approx_od1 = v1O2*v1O2'

b12 = -B(id_passive, id_driving:p:end);  % assume X is standard whitened
GC_from_coef_app_od1 = sum(b12 .* b12)

f12 = F(1, 2:2:end);  % assume X is standard whitened
GC_from_coef_app_pair= sum(f12.*f12)

%rF = [F(1, 1:2:end), F(1, 2:2:end)];
%eR2xy = [
    %R11  R12
    %R12' R22]; 
%rF * eR2xy * rF'
%log(1/(1-rF * eR2xy * rF'));  % should be the same as pariwise result

GC_zero_ave = use_od / len

% solve coefficients
coef_all = erv3 / eR3;
a11 = coef_all( 1:m );
a12 = coef_all((1:m)+m);  % should be the same as B(1,2:p:end)
a13 = coef_all(2*m+1:end);

a32 = -B(3, 2:p:end);
a23 = -B(2, 3:p:end);

disp('------------ new app ------------');
id_x = (1:m);
id_y = (1:m)+m;
id_z = m+m+1 : size(eS3, 1);
Q = inv(eS3);
Qxy = Q(id_x, id_y);
Qyy = Q(id_y, id_y);
Qyz = Q(id_y, id_z);
Qzy = Q(id_z, id_y);
Qzz = Q(id_z, id_z);

d_minus_c = esv3 / eS3 * esv3' - esv2 / eS2 * esv2'

Qyy = inv(eS3)(id_y,id_y);
d_minus_c_expr1 = a12 / Qyy * a12'  % cool!

% if V13=0, V31=0, we have
I11 = eye(m);
I22 = eye(m);
% in general
iQ1 = I22 - V12'*V12 - (V23-V12'*V13)/(V33-V13'*V13)*(V23'-V13'*V12); % verified
iQ3 = I22 - V23*V23' - (V12'-V23*V13')/(I11-V13*V13')*(V12-V13*V23'); % verified
d_minus_c_expr2 = a12 * iQ1 * a12'
d_minus_c_expr3 = a12 * iQ3 * a12'
d_minus_c_expr1_app = a12 * (I22 - V12'*V12 - V23*V23') * a12'

disp('Relation between b and a');
Sp = S(permvec, permvec, :);
SpCov = S2cov(Sp, 100);
%-expm1(-RGrangerT(SpCov))   % x : gc = -ln(1-x)

QSp = zeros(size(Sp));
for k = 1 : fftlen
  QSp(:,:,k) = inv(Sp(:,:,k));
end

b12 = -F(1, 2:2:end);
b12_expr2 = a12 - a13 / Qzz * Qzy;
%b12_expr2 = a12 - a13 * (Qzz \ Qzy);
%norm( b12 - b12_expr2 )  % verify the exact formula

Pyy = Qyy - Qyz/Qzz*Qzy;
gc12_var_reduction = b12 / Pyy * b12'
gc12_var_reduction_ans = [v1O1 v1O2] / [V11 V12; V12' V22] * [v1O1 v1O2]' - v1O1 / V11 * v1O1'

f_1dto3d = @(x) reshape(x, 1,1,[]);
ft_a12 = f_1dto3d( fft(a12, fftlen) );
ft_a13 = f_1dto3d( fft(a13, fftlen) );
ft_Qzy_a = QSp(3:end,2,:);
ft_Qzz_a = QSp(3:end,3:end,:);

ft_b12_app = ft_a12 - rdiv3d( ft_a13, ft_Qzz_a, ft_Qzy_a);
ift_b12_app = ifft(ft_b12_app, fftlen)(1:m);
real( ift_b13_app * ift_b12_app' )
%figure(3); plot(1:m, b12, 1:m, ift_b12_app);
%figure(4); plot(1:m, b12 - ift_b12_app);

%tcov = S2cov(Sp, 300);
%[tB, tD] = ARregression(tcov);
%tS = A2S(tB, tD, fftlen);
%max(abs( (tS - Sp)(:) ))  % see (corrlation) truncation and round-off error

%% exact ft_Qxx
%max(abs( (A2S(B, D_B, fftlen) - Sp)(:) ))  % see (corrlation) truncation and round-off error
HTR = @(x) permute(conj(x), [2, 1, 3:ndims(x)]);
ft_A = fft( cat(3, eye(p), reshape(B, p,p,[])), fftlen, 3);
ft_Qzz = rdiv3d( HTR(ft_A(1,3:end,:)), D_B(1,1), ft_A(1,3:end,:)) + ...
         rdiv3d( HTR(ft_A(2,3:end,:)), D_B(2,2), ft_A(2,3:end,:)) + ...
         rdiv3d( HTR(ft_A(3:end,3:end,:)), D_B(3:end,3:end), ft_A(3:end,3:end,:));
%max(abs( (ft_Qzz_a - ft_Qzz)(:) ))
ft_Qzy = rdiv3d( HTR(ft_A(1,3:end,:)), D_B(1,1), ft_A(1,2,:)) + ...
         rdiv3d( HTR(ft_A(2,3:end,:)), D_B(2,2), ft_A(2,2,:)) + ...
         rdiv3d( HTR(ft_A(3:end,3:end,:)), D_B(3:end,3:end), ft_A(3:end,2,:));
ft_b12_app_expr1 = rdiv3d(ft_A(1,3:end,:), ft_Qzz, ft_Qzy)(:);
ift_b12_app_expr1 = ifft(ft_b12_app_expr1, fftlen)';
figure(5); plot(1:m, b12, 1:m, ift_b12_app_expr1(2:m+1) )

% approximate ft_Qzy
%ft_b12_app_expr2 = (ft_A(1,3:end,:) .* (ft_A(3:end,2,:) + HTR(ft_A(2,3:end,:))) ./ ft_A(3,3,:))(:);
%ift_b12_app_expr2 = real(ifft(ft_b12_app_expr2, fftlen))';
%figure(6); plot(1:m, b12, 1:m, ift_b12_app_expr2(2:m+1) )

% approximate ft_Qzy
ft_b12_app_expr3 = mult3d(ft_A(1,3:end,:), (ft_A(3:end,2,:) + HTR(ft_A(2,3:end,:))))(:);
ift_b12_app_expr3 = real(ifft(ft_b12_app_expr3, fftlen))';
figure(7); plot(1:m, b12, 1:m, ift_b12_app_expr3(2:m+1) )

% approximate b12 in time domain
%b12_app_expr4 = conv(a13, a32)(1:m);
%figure(5); plot(1:m, b12, 1:m, b12_app_expr4 )

% approximate b12 in time domain, good!
b12_app_expr3 = conv(a13,fliplr(a23))(m+1:end) + [0, conv(a13, a32)(1:m-2)];
figure(16); plot(1:m, b12, 1:m-1, b12_app_expr3 )

disp('gc pairwise app');
ift_b12_app_expr1(2:m+1) * ift_b12_app_expr1(2:m+1)'
%ift_b12_app_expr2(2:m+1) * ift_b12_app_expr2(2:m+1)'
ift_b12_app_expr3(2:m+1) * ift_b12_app_expr3(2:m+1)'
b12_app_expr3 * b12_app_expr3'

%figure(3); plot(1:m, b12);
%figure(4); plot(1:m, real(ifft(ft_b12_app,fftlen))(1:m));
%figure(4); plot(real(ifft(ft_b12_app,fftlen)));
%figure(4); plot(1:m, b12 - real(ifft(ft_b12_app,fftlen))(1:m));

%vv = real(ifft(ft_b12_app,fftlen));
%figure(5); plot(1:m, vv(1:m), 1:m, fliplr(vv)(1:m));

%figure(1); plot(1:m, b12);
%figure(2); plot(1:m, a13);

%ift_Qo = real( ifft( conj((ft_Qzy_a ./ ft_Qzz_a)(:)), fftlen) );
%diff_Qo = Qzz \ Qzy - toeplitz([ift_Qo(1); ift_Qo(end:-1:end-m+2)], ift_Qo(1:m));
%figure(19);  imagesc(Qzz \ Qzy);  colorbar();
%figure(20);  imagesc(diff_Qo);  colorbar();  % good approximation

%ift_Qzz = real( ifft(QSp(3,3,:)(:),fftlen) );
%diff_Qzz = Qzz - toeplitz([ift_Qzz(1); ift_Qzz(end:-1:end-m+2)], ift_Qzz(1:m));
%figure(19);  imagesc(Qzz);  colorbar();
%figure(20);  imagesc(diff_Qzz);  colorbar();

%ift_Qzy = real( ifft(QSp(3,2,:)(:),fftlen) );
%diff_Qzy = Qzy - toeplitz([ift_Qzy(1); ift_Qzy(end:-1:end-m+2)], ift_Qzy(1:m));
%figure(19);  imagesc(Qzy);  colorbar();
%figure(20);  imagesc(diff_Qzy);  colorbar();

return
% Check coef and correlation
figure(1);
plot(1:m, -B(id_passive, id_driving:p:end), '-+',...
     1:m, coef_xy, '-x',...
     1:m, r1O2/R11(1), '-o'
     );
legend('Correct', 'By parted matrix', 'By approx');
title(['coef 12 (from ',num2str(id_passive),' to ',num2str(id_driving), ')']);

figure(2);
Q = B3^4;
plot(Q(:,round(0.5*end)), '-b');
hold on
plot(Q(:,round(0.17*end)), '-r');
plot(Q(:,round(0.83*end)), '-g');
title('B3^4 coef');
hold off

n = 5;
s_m_Q = zeros(1, n);
for k=1:n
  s_m_Q(k) = max(abs((B3^k)(:)));
end
figure(3);
plot(1:n, s_m_Q, '-o');

