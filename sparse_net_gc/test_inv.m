% verify inverse formula

randn('state',3);
n = 5;
a11 = randn();
a12 = randn();
a21 = randn();
a22 = randn();
a13 = randn(1, n-2);
a23 = randn(1, n-2);
a31 = randn(n-2, 1);
a32 = randn(n-2, 1);
a33 = randn(n-2, n-2);

A = [
a11 a12 a13
a21 a22 a23
a31 a32 a33];

P1 = [
1                   0 zeros(1,n-2)
-a21/a11            1 zeros(1,n-2)
-a31/a11 zeros(n-2,1) eye(n-2,n-2)
];

Q1 = [
1            -a12/a11    -a13/a11
0                   1    zeros(1,n-2)
zeros(n-2,1) zeros(n-2,1) eye(n-2,n-2)
];

A1 = [
a11                         0     zeros(1,n-2)
0             a22-a21*a12/a11  a23-a21*a13/a11
zeros(n-2,1)  a32-a31*a12/a11  a33-a31*a13/a11
];

max(abs((P1 * A * Q1 - A1)(:)))

P2 = [
1                            0                      zeros(1,n-2)
0                            1                      zeros(1,n-2)
zeros(n-2,1)  -(a32-a31*a12/a11)/(a22-a21*a12/a11)  eye(n-2,n-2)
];

Q2 = [
1                        0   zeros(1,n-2)
0                        1   -(a23-a21*a13/a11)/(a22-a21*a12/a11)
zeros(n-2,1)  zeros(n-2,1)   eye(n-2,n-2)
];

A2 = [
a11                 0           zeros(1,n-2)
0             a22-a21*a12/a11   zeros(1,n-2)
zeros(n-2,1)  zeros(n-2,1)  a33-a31*a13/a11-(a32-a31*a12/a11)*(a23-a21*a13/a11)/(a22-a21*a12/a11)
];

max(abs((P2 * P1 * A * Q1 * Q2 - A2)(:)))

iQ = [
1                 a12/a11   a13/a11
0                        1   (a23-a21*a13/a11)/(a22-a21*a12/a11)
zeros(n-2,1)  zeros(n-2,1)   eye(n-2,n-2)
];

iP = [
1                       0                      zeros(1,n-2)
a21/a11                 1                      zeros(1,n-2)
a31/a11   (a32-a31*a12/a11)/(a22-a21*a12/a11)  eye(n-2,n-2)
];


