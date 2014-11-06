%

n1 = 2;
n2 = 3;
n3 = 5;

id_x = 1:n1;
id_y = (1:n2)+n1;
id_z = (1:n3)+n1+n2;

S = randn(n1+n2+n3);
S = S + S';        % random symatric matrix, not possitive-defined
Sxx = S(id_x, id_x);
Sxy = S(id_x, id_y);
Sxz = S(id_x, id_z);
Syx = S(id_y, id_x);
Syy = S(id_y, id_y);
Syz = S(id_y, id_z);
Szx = S(id_z, id_x);
Szy = S(id_z, id_y);
Szz = S(id_z, id_z);

S_XY = S([id_x,id_y], [id_x,id_y]);

Q = inv(S);            % assume known
Qxx = Q(id_x, id_x);
Qxy = Q(id_x, id_y);
Qxz = Q(id_x, id_z);
Qyx = Q(id_y, id_x);
Qyy = Q(id_y, id_y);
Qyz = Q(id_y, id_z);
Qzx = Q(id_z, id_x);
Qzy = Q(id_z, id_y);
Qzz = Q(id_z, id_z);

s1 = zeros(1, n1);
s2 = randn(1, n2);
s3 = randn(1, n3);
s = [s1 s2 s3];

a = s / S;

b = [s1 s2] / S_XY;

invSXY = [Qxx,Qxy;Qyx,Qyy] - [Qxz;Qyz]/Qzz*[Qzx,Qzy];  % inv( S_XY )
%norm(invSXY - inv(S_XY))

q_b12 = a(id_y) - a(id_z)/Qzz*Qzy;
norm( q_b12 - b(id_y) )

q_iS_XYyy = Qyy - Qyz/Qzz*Qzy;
norm( q_iS_XYyy - inv(S_XY)(id_y,id_y) )

