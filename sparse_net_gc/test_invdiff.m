%

n1 = 2;
n2 = 3;
n3 = 5;

id_x = 1:n1;
id_y = (1:n2)+n1;
id_z = (1:n3)+n1+n2;

Rxyz = randn(n1+n2+n3) + 1i * randn(n1+n2+n3);
%Rxyz = Rxyz+Rxyz';
Rxx = Rxyz(id_x, id_x);
Rxy = Rxyz(id_x, id_y);
Rxz = Rxyz(id_x, id_z);
Ryx = Rxyz(id_y, id_x);
Ryy = Rxyz(id_y, id_y);
Ryz = Rxyz(id_y, id_z);
Rzx = Rxyz(id_z, id_x);
Rzy = Rxyz(id_z, id_y);
Rzz = Rxyz(id_z, id_z);

II = eye(n1+n2+n3);
Ixx = II(id_x, id_x);
Iyy = II(id_y, id_y);
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

R_XOZ = [...
Rxx Oxy Rxz
Oyx Iyy Oyz
Rzx Ozy Rzz];

Ds = inv(Rxyz) - inv(R_XOZ);  % what we want

Q = inv(Rxyz);            % assume known
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
-[Qxy; Oyy; Qzy] / (Iyy - [Ryx Ryz]*[Qxy;Qzy])*[Ryx Oyy Ryz] * [...
Qxx Oxy Qxz
Oyx Iyy Oyz
Qzx Ozy Qzz] + [...
Oxx Qxy Oxz
Qyx Qyy-Iyy Qyz
Ozx Qzy Ozz];

Ds_exp2 = ...             % formula 2
[Qxy; Oyy; Qzy] / Qyy * [Qyx Oyy Qyz] + [...
Oxx Qxy Oxz
Qyx Qyy-Iyy Qyz
Ozx Qzy Ozz];

R_XY = [...
Rxx Rxy
Ryx Ryy];

R_XZ = [...
Rxx Rxz
Rzx Rzz];

iR_XY_exp1 = [Qxx Qxy; Qyx Qyy] - [Qxz;Qyz]/Qzz*[Qzx Qzy];

disp('% verify inverse matrix');
norm(Ds - Ds_exp1)
norm(Ds - Ds_exp2)
norm(inv(R_XY) - iR_XY_exp1)

n4 = 2;
%r1 = zeros(n4, n1) + 1i*zeros(n4, n1);
r1 = randn(n4, n1) + 1i*randn(n4, n1);
r2 = randn(n4, n2) + 1i*randn(n4, n2);
r3 = randn(n4, n3) + 1i*randn(n4, n3);
r = [r1 r2 r3];

qd = r / Rxyz * r' - r / R_XOZ * r';  % the answer

qDs_exp1 = [r1 r3]*[Qxy;Qzy]/Qyy*[Qyx Qyz]*[r1';r3'] + ...
r1*Qxy*r2' + r2*Qyx*r1' + r2*Qyz*r3' + r3*Qzy*r2' + r2*Qyy*r2';

disp('% verify quadratic form (should be zero)');
norm( qd - r * Ds_exp2 * r' )
norm( qd + r2*r2' - qDs_exp1 )

%a12 = r1*Qxy + r2*Qyy + r3*Qzy;
a  = r / Rxyz;
ap = r / Rxyz';
a12  = a (:,id_y);
a12p = ap(:,id_y);
norm( qd + r2*r2' - a12 / Qyy * a12p' )

iQyy_exp1 = Ryy - Ryx/Rxx*Rxy - (Ryz-Ryx/Rxx*Rxz)/(Rzz-Rzx/Rxx*Rxz)*(Rzy-Rzx/Rxx*Rxy);
iQyy_exp2 = Ryy - Ryz/Rzz*Rzy - (Ryx-Ryz/Rzz*Rzx)/(Rxx-Rxz/Rzz*Rzx)*(Rxy-Rxz/Rzz*Rzy);
disp('verify expression for inverse Q^(yy)');
norm( inv(Qyy) - iQyy_exp1 )
norm( inv(Qyy) - iQyy_exp2 )

iQzz_exp1 = Rzz + [Rzx Rzy] / (eye(n1+n2)-[Qxz;Qyz]*[Rzx Rzy]) * [Qxz;Qyz] * Rzz;
iQzz_exp2 = Rzz - [Rzx Rzy] / R_XY * [Rxz;Ryz];

disp('verify expression for inverse Q^(zz)');
norm( inv(Qzz) - iQzz_exp1 )
norm( inv(Qzz) - iQzz_exp2 )

a11 = a(:, id_x);
a13 = a(:, id_z);
b = [r1 r2] / R_XY;
b12 = b(:,id_y);
b12_exp1 = a12 - a13/Qzz*Qzy;
b11 = b(:,id_x);
b11_exp1 = a11 - a13/Qzz*Qzx;

b13_xz = ([r1 r3] / R_XZ)(:, n1+1:end);
a12_exp1 = (b12+b13_xz/Qzz*Qzy) / (Iyy - Qyy\Qyz/Qzz*Qzy);

disp('verify coef update formula');
norm( b12 - b12_exp1 )
norm( b11 - b11_exp1 )
norm( a12 - a12_exp1 )

disp('verify expression for Q^(zy)');
Qzy_exp1 = -Qzz*(Rzy-Rzx/Rxx*Rxy)/(Ryy-Ryx/Rxx*Rxy);
norm( Qzy - Qzy_exp1 )

disp('verify ba');
P = inv(R_XY);
Pxy = P(id_x, id_y);
Pyy = P(id_y, id_y);
norm( Qzz\Qzy - (-[Rzx Rzy]*[Pxy;Pyy]) )
norm( Qzz\[Qzx Qzy] - (-[Rzx Rzy]/R_XY) )
