% S = filterAB2S(A, B, De, fftlen)
% Calculate spectrum of X_t in A * X = B * \epsilon
% A  : p * (p*m) dim matrix, A(:,1:p) = a_0, i.e. first term is included
% B  : p * (p*m) dim matrix, B(:,1:p) = b_0, see also `help filter'
% De : p * p matrix, the variance of noise term (cov(\epsilon))
% S  : p * p * fftlen dim matrix if p>1
%      1 * fftlen vector if p==1
%
% Usage example:
%
%{
A = [1 0, -0.9   0.0, 0.5 0.0;
     0 1, -0.16 -0.8, 0.2 0.5];
B = eye(size(A,1));
fftlen = 1024;
S = filterAB2S(A, B, eye(size(A,1)), fftlen);
rS = permute(S, [3 1 2]);  % so avoid use squeeze()
idx= 1:fftlen;
plot(idx, rS(:,1,1), idx,rS(:,2,2),...
     idx, real(rS(:,1,2)), idx,imag(rS(:,1,2)));
%}
%

function S = filterAB2S(A, B, De, fftlen)
if nargin ~= 4
  error('filterAB2S: Expecting 4 input parameters. See help filterAB2S');
end
p = size(A, 1);
if p==0 || p~=size(B,1) || p~=size(De,1) || p~=size(De,2)...
  || mod(size(A,2),p)~=0 || mod(size(B,2),p)~=0
  error('filterAB2S: input argument inconsistent!');
end

if p==1
  S = abs(fft(B,fftlen) ./ fft(A,fftlen)).^2 * De;
else
  if ndims(A)==2
    %m = round(m/p);  % currently not used
    %A = cat(3,eye(p),reshape(A,p,p,[]));  % convert A to 3-dim array
    %B = cat(3,eye(p),reshape(B,p,p,[]));  % convert B to 3-dim array
    A = cat(3, reshape(A,p,p,[]), zeros(p,p));  % convert A to 3-dim array
    B = cat(3, reshape(B,p,p,[]), zeros(p,p));  % convert B to 3-dim array
  end
  wA = fft(A,fftlen,3);
  wB = fft(B,fftlen,3);
  hDe = chol(De,'lower');
  S = zeros(p,p,fftlen);
  for k = 1:fftlen
    h = wA(:,:,k) \ (wB(:,:,k) * hDe);
    S(:,:,k) = h*h';
  end
end

end %function

% test
%{
a = [1.0 0.5 0.1];
s0 = squeeze(A2S(a(2:end), 1.3, 7))';
s1 = filterAB2S(a, 1, 1.3, 7);
norm(s0 - s1)  % should be around machine epsilon
%}

% test
%{
A = [1 0, -0.9   0.0, 0.5 0.0;
     0 1, -0.16 -0.8, 0.2 0.5];
B = eye(size(A,1));
rand('state',1);
x=rand(size(A,1));
De = x*x';
fftlen = 17;
S0 = A2S(A(:, 3:end), De, fftlen);
S1 = filterAB2S(A, B, De, fftlen);
S2 = filterAB2S(A, chol(De,'lower'), eye(size(A,1)), fftlen);
norm(S0(:) - S1(:))  % should be around machine epsilon
norm(S1(:) - S2(:))  % should be 0
%}
