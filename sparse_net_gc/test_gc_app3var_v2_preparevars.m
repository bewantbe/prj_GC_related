
id_rearrange = bsxfun(@plus, permvec', p*(0:m));
covz = covz_orig(id_rearrange, id_rearrange);

id_passive = permvec(1);
id_driving = permvec(2);

% do a 2-var GC
l = size(R, 2);
idx = [id_passive:p:l; id_driving:p:l];
F = ARregression([R(id_passive,idx); R(id_driving,idx)]);
B = ARregression(S2cov(S(permvec,permvec,:), m));

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

erv3 = [r1O1 r1O2 r1O3];
eR3 = [
    R11  R12  R13
    R12' R22  R23
    R13' R23' R33];
