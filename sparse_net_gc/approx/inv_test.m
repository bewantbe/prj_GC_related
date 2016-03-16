%
if 0
a = [0.5 0.2 0.1];

od = 6;

fftlen = 1024;
S = A2S(a, eye(size(a,1)), fftlen);
R = S2cov(S, od);
V = R2covz(R);
Q = inv(V);
Q(abs(Q)<1e-14)=0;
tA = toeplitz([1; zeros(od,1)], [1 a zeros(1, od-size(a,2))]);
tQ = tA' * tA;
tQ - Q
maxerr = @(x) max(abs(x(:)));
%maxerr(Q-tQ)

end

%% matrix case

a = [
 0.5 0.1 0.21 0.15
-0.2 0.4 0.33 0.09];

%a = [0.5 0.2 0.1];

od = 3;

fftlen = 1024;
S = A2S(a, eye(size(a,1)), fftlen);
R = S2cov(S, od);
V = R2covz(R);
Q = inv(V);
Q(abs(Q)<1e-14)=0;

%tA = toeplitz([1; zeros(od,1)], [1 a zeros(1, od-size(a,2))]);

p = size(a,1);
A3d = cat(3, eye(p), reshape(a,p,p,[]), zeros(p,p, od-size(a,2)/p));
tA = zeros((od+1)*p);
tB = zeros((od+1)*p);
for k=0:od
  tA(k*p+1:(k+1)*p, k*p+1:end) = reshape(A3d(:,:,1:end-k), p, []);
  tB(k*p+1:(k+1)*p, (k+1)*p+1:end) = reshape(permute(flipdim(A3d(:,:,k+2:end),3),[2 1 3]), p, []);
end

%tQ = tA' * tA - tB' * tB;
tQ = tA' * tA;
tQ - Q
maxerr = @(x) max(abs(x(:)));



%Q_g = ...
%[Id a       O
%a' Id+a'*a  a
%O    a'     Id]

