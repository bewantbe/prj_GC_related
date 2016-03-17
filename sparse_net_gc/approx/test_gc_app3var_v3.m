% Time domain app

pow2ceil = @(x) 2^ceil(log2(x));
maxerr = @(x) max(abs(x(:)));

fit_od = 40;
use_od = 120;
m = use_od;

ed = 0;
tic;
if ~exist('ed', 'var') || isempty(ed) || ~ed
ed = true;

gen_data_n10_c1;
%gen_data_n40_c1;  % 1 40
%gen_data_n100_c1;  % 32  32

    % whiten the covariance in frequency domain
    [A2d, D] = ARregressionpd(getcovzpd(X, fit_od), p);
    S = A2S(A2d, D, max(pow2ceil(8*use_od), 1024));
    %S = StdWhiteS(S);
    R = S2cov(S, use_od);
    covz = R2covz(R);
    covz_orig = covz;

end
toc;

% analyse x <- y
id_x = 1;
id_y = 2;

id_z = 1:p;
id_z([id_x id_y]) = [];
permvec = [id_x id_y id_z];

test_gc_app3var_v2_preparevars;

Q = inv(eR3);
a12 = (erv3 * Q)(m+1:2*m);

id_x = (1:m);
id_y = (1:m)+m;
id_z = m+m+1 : size(eS3, 1);
Q = inv(eS3);
Qxy = Q(id_x, id_y);
Qyy = Q(id_y, id_y);
Qyz = Q(id_y, id_z);
Qzy = Q(id_z, id_y);
Qzz = Q(id_z, id_z);


maxerr( a12(1:fit_od) + A2d(id_x, id_y:p:end) )



