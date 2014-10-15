% verify inverse formula

randn('state',5);
n1 = 2;
n2 = 2;
n3 = 2;
a11 = randn(n1, n1);
a12 = randn(n1, n2);
a21 = randn(n2, n1);
a22 = randn(n2, n2);
a13 = randn(n1, n3);
a23 = randn(n2, n3);
a31 = randn(n3, n1);
a32 = randn(n3, n2);
a33 = randn(n3, n3);

A = [
a11 a12 a13
a21 a22 a23
a31 a32 a33];

P1 = [
eye(n1,n1)  zeros(n1,n2)  zeros(n1,n3)
-a21/a11      eye(n2,n2)  zeros(n2,n3)
-a31/a11    zeros(n3,n2)    eye(n3,n3)
];

Q1 = [
eye(n1,n1)        -a11\a12      -a11\a13
zeros(n2,n1)    eye(n2,n2)  zeros(n2,n3)
zeros(n3,n1)  zeros(n3,n2)    eye(n3,n3)
];

A1 = [
a11              zeros(n1,n2)     zeros(n1,n3)
zeros(n2,n1)  a22-a21/a11*a12  a23-a21/a11*a13
zeros(n3,n1)  a32-a31/a11*a12  a33-a31/a11*a13
];

max(abs((P1 * A * Q1 - A1)(:)))

P2 = [
  eye(n1,n1)  zeros(n1,n2)  zeros(n1,n3)
zeros(n2,n1)    eye(n2,n2)  zeros(n2,n3)
zeros(n3,n1)  -(a32-a31/a11*a12)/(a22-a21/a11*a12)    eye(n3,n3)
];

Q2 = [
  eye(n1,n1)  zeros(n1,n2)  zeros(n1,n3)
zeros(n2,n1)    eye(n2,n2)  -(a22-a21/a11*a12)\(a23-a21/a11*a13)
zeros(n3,n1)  zeros(n3,n2)    eye(n3,n3)
];

A2 = [
         a11     zeros(n1,n2)  zeros(n1,n3)
zeros(n2,n1)  a22-a21/a11*a12  zeros(n2,n3)
zeros(n3,n1)     zeros(n3,n2)  a33-a31/a11*a13-(a32-a31/a11*a12)/(a22-a21/a11*a12)*(a23-a21/a11*a13)
];

max(abs((P2 * P1 * A * Q1 * Q2 - A2)(:)))

%iQ = [
%  eye(n1,n1)      -a11\a12     -a11\a13
%zeros(n2,n1)    eye(n2,n2)  -(a22-a21/a11*a12)\(a23-a21/a11*a13)
%zeros(n3,n1)  zeros(n3,n2)    eye(n3,n3)
%];

%iP = [
%  eye(n1,n1)  zeros(n1,n2)  zeros(n1,n3)
%    -a21/a11    eye(n2,n2)  zeros(n2,n3)
%    -a31/a11  -(a32-a31/a11*a12)/(a22-a21/a11*a12)    eye(n3,n3)
%];

%max(abs(( Q2*Q1 - iQ)(:)))
%max(abs(( P1*P2 - iP)(:)))

iQ = [
  eye(n1,n1)      -a11\a12     a11\a12*((a22-a21/a11*a12)\(a23-a21/a11*a13))-a11\a13
zeros(n2,n1)    eye(n2,n2)  -(a22-a21/a11*a12)\(a23-a21/a11*a13)
zeros(n3,n1)  zeros(n3,n2)    eye(n3,n3)
];

iP = [
  eye(n1,n1)  zeros(n1,n2)  zeros(n1,n3)
    -a21/a11    eye(n2,n2)  zeros(n2,n3)
    (a32-a31/a11*a12)/(a22-a21/a11*a12)*a21/a11-a31/a11  -(a32-a31/a11*a12)/(a22-a21/a11*a12)    eye(n3,n3)
];

max(abs(( Q1*Q2 - iQ)(:)))
max(abs(( P2*P1 - iP)(:)))

%max(abs(( inv(A) - iQ * inv(A2) * iP )(:)))
max(abs(( inv(A) - iQ * inv(A2) * iP )(:)))


