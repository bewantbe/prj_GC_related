
%eS3 = [
    %V11  V12  V13
    %V12' V22  V23
    %V13' V23' V33];

eS2z = [
    V22  V23
    V23' V33];

n1 = size(V11, 1);
n2 = size(V22, 1)+size(V33, 1);

v = inv(eS3);
b21 = v(n1+1:end, 1:n1);
b22 = v(n1+1:end, n1+1:end);
a12 = eS3(1:n1, n1+1:end);
vv = (eye(n2) + b21/(eye(n1)-a12*b21)*a12) * b22;  % should equal to inv(eS2z)
norm( inv(eS2z) - vv )

n1 = size(V11, 1);
n2 = size(V22, 1);
n3 = size(V33, 1);
vv = (eye(n1+n3) + v([1:n1,n1+n2+1:end], n1+1:n1+n2) / (eye(n2) - eS3(n1+1:n1+n2, [1:n1,n1+n2+1:end]) * v([1:n1,n1+n2+1:end], n1+1:n1+n2)) * eS3(n1+1:n1+n2, [1:n1,n1+n2+1:end])) * v([1:n1, n1+n2+1:end],[1:n1, n1+n2+1:end]);
norm( inv(eS2) - vv )
%eS3rp = [
    %V11  V12  V13
    %V12' V22  V23
    %V13' V23' V33];
