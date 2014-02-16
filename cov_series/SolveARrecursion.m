% Calculate coefficients for k-th cov
% k-th(k>=0) order covariance (E(X[t]*X[t-k]')) can be obtained by
%  [s_lambda, s_V] = SolveARrecursion(A, De);
%  B = zeros(p,p);
%  for j=1:mp
%    B = B + s_lambda(j)^k * s_V(:,:,j);
%  end
%  real(B)

function [s_lambda, s_V] = SolveARrecursion(A, De)
[p, mp] = size(A);
m = round(mp/p);

% solve R for initial values
fftlen = 2^8;
S = A2S_new(A,De,fftlen);
V_d3 = real(ifft(S, size(S,3), 3));
V = zeros(mp,p);
for j=1:m
  V(end-j*p+1:end-(j-1)*p,:) = V_d3(:,:,j);
end

B = zeros(mp, mp);
B(1:p, :) = -A;
B(p+1:mp+1:mp*(mp-p)) = 1;

[P, dl] = eig(B);
s_lambda = diag(dl).';  % I prefer to row vector here

% note: V[k] = B * V[k-1]  =>  V[m+k] = P * Lambda^k * inv(P) * V[m]
P_end = P(mp-p+1:mp, :);
U = P \ V;
s_V = zeros(p,p,mp);
for j=1:mp
  s_V(:,:,j) = P_end(:,j) * U(j,:);
end

end
