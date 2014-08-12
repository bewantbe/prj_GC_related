%

if exist('are_you_joking', 'var')
clear('pmif');
pmif.neuron_model = 'LIF';
pmif.net  = 'net_3_06';
pmif.scee = 0.01;
pmif.pr   = 1.0;
pmif.ps   = 0.012;
pmif.t    = 1e7;
pmif.stv  = 0.5;
[X, ISI, ras] = gen_HH(pmif);
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


% Make S^(xx) identical matrix
% i.e. Assume `srd' is purely white for each variables
id_p   = 1 : p : (p*(m+1));
id_p_2 = 1 : p*p*(m+1)+p : p*p*(m+1)*(m+1);
for k = 1 : p
    covz(id_p,id_p) = diag(covz(id_p_2));
    id_p = id_p + 1;
    id_p_2 = id_p_2 + p*(m+1) + 1;
end
covz_orig = covz;

else
covz = covz_orig;
end

[GC_srd_covz, Deps, AA] = pos_nGrangerT2RZ(covz, p);
GC_srd_covz

% Permute the variables in covz
% e.g. to get y->z, set permvec = [3 2 1]
%permvec = [3 2 1];              % variable index after permutation
permvec = [3 1 2];              % variable index after permutation
id_rearrange = bsxfun(@plus, permvec', p*(0:m));
covz = covz_orig(id_rearrange, :)(:, id_rearrange);  % tremble matlab!

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
quotient_core_expension =...
    1 - (1 - esv3 * (B3^0 + B3^1 + B3^2) * esv3') /...
        (1 - esv2 * (B2^0 + B2^1 + B2^2) * esv2')
quotient_core_expension_low =...
    1 - (1 - esv3 * (B3^0 + B3^1) * esv3') /...
        (1 - esv2 * B2^0 * esv2')
quotient_core_expension_low_v2 =...
    v1O2*v1O2' + esv3 * B3 * esv3'

GC_approx_od2 = v1O2*v1O2' - 2*v1O2 * V23 * v1O3'

GC_approx_od1 = v1O2*v1O2'

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

% Use covariance to calculate GC
%erv2 = [r1O1 r1O3];
%eR2 = [
    %R11  R13
    %R13' R33];
%log( (R11(1,1) - erv2 / eR2 * erv2') /...
     %(R11(1,1) - erv3 / eR3 * erv3') )

% Check coef and correlation
id_passive = permvec(1);
id_driving = permvec(2);

figure(1);
plot(1:m, -AA(id_passive, id_driving:p:end), '-+',...
    1:m, coef_xy, '-x',...
    1:m, r1O2/R11(1), '-o'
    );
legend('Correct', 'By parted matrix', 'By approx');
title(['coef 12, from ',num2str(id_passive),' to ',num2str(id_driving)]);

c_j       = coef_xy;
cov_srdxy = r1O2/R11(1);

