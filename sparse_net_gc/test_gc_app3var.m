%

% 'net_2_2'    scee=0.01;  pr=0.24, 0.38, 0.5, 1.7; ps=0.02; simu_time=1e7, 5e7;
% 'net_2_2'    scee=0.01;  pr=0.24, 0.38, 0.5, 1.7; ps=0.02; simu_time=1e6

mode_IF = 'IF';
mode_ST = 0;
netstr = 'net_3_06';  p = 3;
scee = 0.02;
%pr = 0.8;
%pr = 1.7;
pr = 1.7;
ps = 0.02;
simu_time = 1e7;
extst = '--RC-filter';

if ~exist('extst','var')
    extst = '';
end
if strcmpi(mode_IF,'ExpIF')
    extst = ['ExpIF ',extst];
end
if exist('dt','var')
    extst = [extst, sprintf(' -dt %.16e',dt)];
end
if ~exist('stv','var')
    stv = 1/2;
end
[X, ISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time, stv, extst);

%GC_regression                  % get rd and srd

aic_od = chooseOrder(X,'AIC');
bic_od = chooseOrder(X,'BIC');
srd = WhiteningFilter(X, aic_od);

disp(['bic od = ', num2str(bic_od)]);
% the fitting order used to calculate GC
use_od = bic_od;
%use_od = 2;
m = use_od;

GC_X   = pos_nGrangerT2(X, use_od)
clear('X');
covz = getcovz(srd, use_od);

GC_srd_whole = pos_nGrangerT2(srd, use_od)
clear('srd');

covz_orig = covz;
id_p   = 1 : p : (p*(m+1));
id_p_2 = 1 : p*p*(m+1)+p : p*p*(m+1)*(m+1);
for k = 1 : p
    covz(id_p,id_p) = diag(covz(id_p_2));
    id_p = id_p + 1;
    id_p_2 = id_p_2 + p*(m+1) + 1;
end
[GC_srd_covz, Deps, AA] = pos_nGrangerT2RZ(covz, p);
GC_srd_covz


% We want to get y->z
permvec = [3 2 1];              % variable index after permutation
permmat(:,[permvec]) = eye(p);
permmat_big = zeros(p*(m+1));
for k=1:m+1
    id = (k-1)*p+1 : k*p;
    permmat_big(id, id) = permmat;
end
covz = permmat_big * covz_orig * permmat_big';

%get GC y->x
% here V = S
id_p = p:p:(p*(m+1)-1);
R11 = covz(id_p+1, id_p+1);
R12 = covz(id_p+1, id_p+2);
R13 = covz(id_p+1, id_p+3);
R22 = covz(id_p+2, id_p+2);
R23 = covz(id_p+2, id_p+3);
R33 = covz(id_p+3, id_p+3);
r1O2 = covz(1, id_p+2);
r1O3 = covz(1, id_p+3);

V11 = R11 / sqrt(R11(1)*R11(1));
V12 = R12 / sqrt(R11(1)*R22(1));
V13 = R13 / sqrt(R11(1)*R33(1));
V22 = R22 / sqrt(R22(1)*R22(1));
V23 = R23 / sqrt(R22(1)*R33(1));
V33 = R33 / sqrt(R33(1)*R33(1));
v1O2 = r1O2 / sqrt(R11(1)*R22(1));
v1O3 = r1O3 / sqrt(R11(1)*R33(1));

esv2 = [zeros(1,m) v1O3];
esv3 = [zeros(1,m) v1O2 v1O3];
Idm = eye(m);
Ide = eye(m*(p-2));
eS2 = [
    Idm  V13
    V13' Ide];
eS3 = [
    Idm  V12  V13
    V12' Idm  V23
    V13' V23' Ide];

GC_fomula = log(...
    (1 - esv2*inv(eS2)*esv2')/...
    (1 - esv3*inv(eS3)*esv3'))

GC_approx_2 = v1O2*v1O2'

% solve coefficients
erv3 = [zeros(1,m) r1O2 r1O3];
eR3 = [
    R11  R12  R13
    R12' R22  R23
    R13' R23' R33];
coef_all = erv3 / eR3;
coef_xx = coef_all( 1:m );
coef_xy = coef_all((1:m)+m);
coef_xz = coef_all((1:m)+2*m);

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
matname = sprintf('net_3_06_scee=%g_pr=%g_ps=%g_t=%g_c_j_and_cov_srdyx_j', scee,pr,ps,simu_time);
save('-v7', matname, 'm', 'c_j', 'cov_srdxy.mat');

