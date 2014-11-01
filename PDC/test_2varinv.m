%

n1 = 2;
n2 = 3;
a11 = randn(n1,n1);
a12 = randn(n1,n2);
a21 = randn(n2,n1);
a22 = randn(n2,n2);

A = [a11, a12; a21, a22];
iA = inv(A)

a1 = inv(a11-a12/a22*a21);
a2 = inv(a22-a21/a11*a12);
iA_p = [
a1 -a1*a12/a22
-a2*a21/a11 a2]

% following should be the same matrix
inv(a22)
b21 = iA(n1+1:end, 1:n1);
inv(eye(n2,n2) - b21 * a12) * iA(n1+1:end, n1+1:end)
if n1 == 1
  (eye(n2,n2) + b21 * a12 / (1-a12*b21)) * iA(n1+1:end, n1+1:end)
else
  (eye(n2,n2) + b21 / (eye(n1)-a12*b21) * a12) * iA(n1+1:end, n1+1:end)
end
