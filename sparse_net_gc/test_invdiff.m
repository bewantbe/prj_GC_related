%

n1 = 2;
n2 = 3;
n3 = 5;

id_x = 1:n1;
id_y = (1:n2)+n1;
id_z = (1:n3)+n1+n2;

Sxyz = randn(n1+n2+n3);
Sxyz = Sxyz+Sxyz';
Sxx = Sxyz(id_x, id_x);
Sxy = Sxyz(id_x, id_y);
Sxz = Sxyz(id_x, id_z);
Syx = Sxyz(id_y, id_x);
Syy = Sxyz(id_y, id_y);
Syz = Sxyz(id_y, id_z);
Szx = Sxyz(id_z, id_x);
Szy = Sxyz(id_z, id_y);
Szz = Sxyz(id_z, id_z);

II = eye(n1+n2+n3);
Ixx = II(id_x, id_x);
Ixy = II(id_x, id_y);
Ixz = II(id_x, id_z);
Iyx = II(id_y, id_x);
Iyy = II(id_y, id_y);
Iyz = II(id_y, id_z);
Izx = II(id_z, id_x);
Izy = II(id_z, id_y);
Izz = II(id_z, id_z);

Oxx = zeros(n1, n1);
Oxy = zeros(n1, n2);
Oxz = zeros(n1, n3);
Oyx = zeros(n2, n1);
Oyy = zeros(n2, n2);
Oyz = zeros(n2, n3);
Ozx = zeros(n3, n1);
Ozy = zeros(n3, n2);
Ozz = zeros(n3, n3);

T = [...
Sxx Oxy Sxz
Oyx Iyy Oyz
Szx Ozy Szz];

Ds = inv(Sxyz) - inv(T);  % what we want

Q = inv(Sxyz);            % assume known
Qxx = Q(id_x, id_x);
Qxy = Q(id_x, id_y);
Qxz = Q(id_x, id_z);
Qyx = Q(id_y, id_x);
Qyy = Q(id_y, id_y);
Qyz = Q(id_y, id_z);
Qzx = Q(id_z, id_x);
Qzy = Q(id_z, id_y);
Qzz = Q(id_z, id_z);

Ds_exp1 = ...             % formula 1
-[Qxy; Oyy; Qzy] / (Iyy - [Syx Syz]*[Qxy;Qzy])*[Syx Oyy Syz] * [...
Qxx Oxy Qxz
Oyx Iyy Oyz
Qzx Ozy Qzz] + [...
Oxx Qxy Oxz
Qyx Qyy-Iyy Qyz
Ozx Qzy Ozz];

norm(Ds - Ds_exp1)

Ds_exp2 = ...             % formula 2
[Qxy; Oyy; Qzy] / Qyy * [Qyx Oyy Qyz] + [...
Oxx Qxy Oxz
Qyx Qyy-Iyy Qyz
Ozx Qzy Ozz];

norm(Ds - Ds_exp2)

%s1 = randn(1, n1);
s1 = zeros(1, n1);
s2 = randn(1, n2);
s3 = randn(1, n3);
s = [s1 s2 s3];

%qd = s * Ds * s';
qd = s / Sxyz * s' - s / T * s';

qd - s * Ds_exp2 * s'

qDs_exp1 = [s1 s3]*[Qxy;Qzy]/Qyy*[Qyx Qyz]*[s1';s3'] + ...
2*s1*Qxy*s2' + 2*s2*Qyz*s3' + s2*Qyy*s2';
%s1*Qxy*s2' + s2*Qyx*s1' + s2*Qyz*s3' + s3*Qzy*s2' + s2*Qyy*s2';

qd + s2*s2' - qDs_exp1

%v = s1*Qxy + s2*Qyy + s3*Qzy;
v = (s / Sxyz)(id_y);
qd + s2*s2' - v / Qyy * v'

iQyy_exp1 = Syy - Syx/Sxx*Sxy - (Syz-Syx/Sxx*Sxz)/(Szz-Szx/Sxx*Sxz)*(Szy-Szx/Sxx*Sxy);
iQyy_exp2 = Syy - Syz/Szz*Szy - (Syx-Syz/Szz*Szx)/(Sxx-Sxz/Szz*Szx)*(Sxy-Sxz/Szz*Szy);
norm( inv(Qyy) - iQyy_exp1 )
norm( inv(Qyy) - iQyy_exp2 )

