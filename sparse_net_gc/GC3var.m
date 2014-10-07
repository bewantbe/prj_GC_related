
function gc = GC3var(id_passive, id_driving, covz_orig, p)
m = round(size(covz_orig,1) / p) - 1;
if ((m+1)*p ~= size(covz_orig,1))
  error('inconsistent input');
end

% Permute the variables in covz
% e.g. to get y->z, set permvec = [3 2 1]
% variable index after permutation
permvec = 1:p;
permvec([id_passive id_driving]) = [];
permvec = [id_passive id_driving permvec];
id_rearrange = bsxfun(@plus, permvec', p*(0:m));
covz = covz_orig(id_rearrange, id_rearrange);

%fprintf('analyse GC %d -> %d\n', id_driving, id_passive);

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

%esv2 = [v1O1 v1O3];
%eS2 = [
    %V11  V13
    %V13' V33];
%esv3 = [v1O1 v1O2 v1O3];
%eS3 = [
    %V11  V12  V13
    %V12' V22  V23
    %V13' V23' V33];

%GC_fomula = log(...
    %(1 - esv2 / eS2 * esv2')/...
    %(1 - esv3 / eS3 * esv3'));

% iterative
%B2 = eye(size(eS2)) - eS2;
%B3 = eye(size(eS3)) - eS3;

%quotient_core =...
    %1 - (1 - esv3 / eS3 * esv3') /...
        %(1 - esv2 / eS2 * esv2')
%quotient_core_app =...
    %esv3 / eS3 * esv3' - esv2 / eS2 * esv2'

%fprintf('norm of B2 = %f\n', norm(B2));
%fprintf('norm of B3 = %f\n', norm(B3));

%quotient_core_expension_od4_v1 =...
    %1 - (1 - esv3 * (B3^0 + B3^1 + B3^2 + B3^3 + B3^4) * esv3') /...
        %(1 - esv2 * (B2^0 + B2^1 + B2^2 + B2^3 + B2^4) * esv2');

%quotient_core_expension_od2_v1 =...
    %1 - (1 - esv3 * (B3^0 + B3^1 + B3^2) * esv3') /...
        %(1 - esv2 * (B2^0 + B2^1 + B2^2) * esv2');
%quotient_core_expension_od1_v1 =...
    %1 - (1 - esv3 * (B3^0 + B3^1) * esv3') /...
        %(1 - esv2 * B2^0 * esv2');
%quotient_core_expension_od1_v2 =...
    %v1O2*v1O2' + esv3 * B3 * esv3';

GC_approx_od2 = v1O2*v1O2' - 2*v1O2 * V23 * v1O3';
%GC_approx_od2_wrong = v1O2*v1O2' - v1O2 * V23 * v1O3';
%GC_approx_od1 = v1O2*v1O2';

%GC_zero_ave = use_od / len;

gc = GC_approx_od2;

%% solve coefficients
%erv3 = [r1O1 r1O2 r1O3];
%eR3 = [
    %R11  R12  R13
    %R12' R22  R23
    %R13' R23' R33];
%coef_all = erv3 / eR3;
%coef_xx = coef_all( 1:m );
%coef_xy = coef_all((1:m)+m);
%coef_xz = coef_all(2*m+1:end);

%coef_xy_app = r1O2/R11(1);
