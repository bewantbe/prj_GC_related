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
    A = [-0.8   0.0   0.0  0.5 -0.07   0.0;
          0.05 -0.9   0.0  0.0  0.8    0.0;
          0.0   0.04 -0.5  0.0  0.03   0.2];
    fftlen = 1024;
    S = A2S(A, D, fftlen);
    S = StdWhiteS(S);
    od = 90;
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

[GC_srd_covz, Deps, B] = pos_nGrangerT2RZ(covz, p);
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
%permvec = [3 1 2];              % variable index after permutation
permvec = [1 2 3];              % variable index after permutation
%permvec = [1 3 2];              % variable index after permutation
id_rearrange = bsxfun(@plus, permvec', p*(0:m));
covz = covz_orig(id_rearrange, id_rearrange);

id_passive = permvec(1);
id_driving = permvec(2);

% do a 2-var GC
l = size(R, 2);
idx = [id_passive:p:l; id_driving:p:l];
[~, ~, F] = RGrangerT([R(id_passive,idx); R(id_driving,idx)]);

fprintf('analyse GC %d -> %d\n', id_driving, id_passive);

%
% Get GC 2->1  (y->x)
%

% Rearrange the order of coefficients
% from block toeplitz to toeplitz blocks
id_p = p:p:(p*(m+1)-1);
id_p_3 = bsxfun(@plus, [3:p]', p*(1:m))(:).';
R11 = covz(id_p+1, id_p+1);        % should close to diagonal matrix
R12 = covz(id_p+1, id_p+2);
R13 = covz(id_p+1, id_p_3);
R22 = covz(id_p+2, id_p+2);        % should close to diagonal matrix
R23 = covz(id_p+2, id_p_3);
R33 = covz(id_p_3, id_p_3);        % should close to diagonal matrix
r1O1 = covz(1, id_p+1);            % v^(1|1), should close to zero
r1O2 = covz(1, id_p+2);            % v^(1|2)
r1O3 = covz(1, id_p_3);            % v^(1|3)

covz_diag = diag(covz);
invsqrt_var1 = diag(1./sqrt(covz_diag(1)));
invsqrt_var1n = diag(1./sqrt(covz_diag(id_p+1)));
invsqrt_var2n = diag(1./sqrt(covz_diag(id_p+2)));
invsqrt_var3n = diag(1./sqrt(covz_diag(id_p_3)));

% note here V := S
V11 = invsqrt_var1n * R11 * invsqrt_var1n;
V12 = invsqrt_var1n * R12 * invsqrt_var2n;
V13 = invsqrt_var1n * R13 * invsqrt_var3n;
V22 = invsqrt_var2n * R22 * invsqrt_var2n;
V23 = invsqrt_var2n * R23 * invsqrt_var3n;
V33 = invsqrt_var3n * R33 * invsqrt_var3n;
v1O1= invsqrt_var1 * r1O1 * invsqrt_var1n; % s^(1|1), should close to zero
v1O2= invsqrt_var1 * r1O2 * invsqrt_var2n;
v1O3= invsqrt_var1 * r1O3 * invsqrt_var3n;

esv2 = [v1O1 v1O3];
eS2 = [
    V11  V13
    V13' V33];
esv3 = [v1O1 v1O2 v1O3];
eS3 = [
    V11  V12  V13
    V12' V22  V23
    V13' V23' V33];

GC_fomula = log(...
    (1 - esv2 / eS2 * esv2')/...
    (1 - esv3 / eS3 * esv3'))

% iterative
B2 = eye(size(eS2)) - eS2;
B3 = eye(size(eS3)) - eS3;

quotient_core =...
    1 - (1 - esv3 / eS3 * esv3') /...
        (1 - esv2 / eS2 * esv2')
quotient_core_app =...
    esv3 / eS3 * esv3' - esv2 / eS2 * esv2'

fprintf('norm of B2 = %f\n', norm(B2));
fprintf('norm of B3 = %f\n', norm(B3));

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

b = B(id_passive, id_driving:p:end);  % assume X is standard whitened
GC_from_coef_app_od1 = sum(b.*b)

b = F(1, 2:2:end);  % assume X is standard whitened
GC_from_coef_app_pair= sum(b.*b)

%rF = [F(1, 1:2:end), F(1, 2:2:end)];
%eR2xy = [
    %R11  R12
    %R12' R22]; 
%rF * eR2xy * rF'
%log(1/(1-rF * eR2xy * rF'));  % should be the same as pariwise result

GC_zero_ave = use_od / len

% solve coefficients
erv3 = [r1O1 r1O2 r1O3];
eR3 = [
    R11  R12  R13
    R12' R22  R23
    R13' R23' R33];
coef_all = erv3 / eR3;
coef_xx = coef_all( 1:m );
coef_xy = coef_all((1:m)+m);
coef_xz = coef_all(2*m+1:end);

disp('new app');
esv3 / eS3 * esv3' - esv2 / eS2 * esv2'
n1 = size(V11, 1);
n2 = size(V22, 1);
n3 = size(V33, 1);

O11 = zeros(n1,n1);
O12 = zeros(n1,n2);
O13 = zeros(n1,n3);
O22 = zeros(n2,n2);
O23 = zeros(n2,n3);
O33 = zeros(n3,n3);

I11 = eye(n1);
I22 = eye(n2);
I33 = eye(n3);

iv  = inv(eS3);
Q11 = iv(1:n1, 1:n1);
Q12 = iv(1:n1, n1+1:n1+n2);
Q13 = iv(1:n1, n1+n2+1:end);
Q22 = iv(n1+1:n1+n2, n1+1:n1+n2);
Q23 = iv(n1+1:n1+n2, n1+n2+1:end);
Q33 = iv(n1+n2+1:end, n1+n2+1:end);

v1O3 * Q23' / Q22 * Q23 * v1O3' + 2 * v1O2*Q23*v1O3' + v1O2*Q22*v1O2'
[v1O2 v1O3] * [Q22  Q23; Q23' Q23' / Q22 * Q23] * [v1O2 v1O3]'
(v1O3 * Q23' / Q22 + v1O2) * Q23 * v1O3' + v1O2*( Q22*v1O2' + Q23*v1O3')
(v1O3*Q23' + v1O2*Q22) / Q22 * (v1O3*Q23' + v1O2*Q22)'
b / Q22 * b'  % cool!
coef_xy / Q22 * coef_xy'  % cool!

max(abs(b+coef_xy))  % not very small
plot(1:od, b+coef_xy);

%C22 = inv(I22 - V12'*V12);
%ivQy1 = C22 + C22*V23*inv(I33 - V23'*C22*V23)*V23'*C22;
%ivSy = inv(
%[V11  V12  O13
 %V12' V22  V23
 %O13' V23' V33]);
%ivQy = ivSy(n1+1:n1+n2, n1+1:n1+n2);
%norm( ivQy - ivQy1 )

%iQapp = I22 - V12'*V12 - V23*V23';
%norm( inv(ivQy) - iQapp)   % verified !!

% if V13=0, V31=0, we have
b * (I22 - V12'*V12 - V23*V23') * b'
% in general
iQ1 = I22 - V12'*V12 - (V23-V12'*V13)/(I33-V13'*V13)*(V23'-V13'*V12); % verified
iQ3 = I22 - V23*V23' - (V12'-V23*V13')/(I11-V13*V13')*(V12-V13*V23'); % verified
%norm(inv(Q22) - iQ1)
%norm(inv(Q22) - iQ3)
b * iQ1 * b'
b * iQ3 * b'


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

