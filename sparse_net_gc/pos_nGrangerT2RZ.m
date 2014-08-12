% Multi-variate time series Granger causality test in time domain  v1.2
% this version use completely symmetric positive definite covx from Xt
% time and memory cost is little bigger than nGrangerT.m

% time   cost is about: O(p^3 * m^2)
% memory cost is about: O((m*p)^2)

function [GC, Deps, Aall] = pos_nGrangerT2RZ(covz, p, showcond)
if (exist('showcond', 'var')==0)
    showcond = 0;
end

m = round(size(covz,1)/p) - 1;

R = zeros(p, (m+1)*p);
R(:,1:p*(m+1)) = covz(1:p,1:p*(m+1));
%R(:,1:p*(m+1)) = [covz(p+1:p+p, p+1:p+p) covz(1:p,p+1:p*(m+1))];
%covz = covz(1:m*p, 1:m*p);
covz = covz(p+1:p+m*p, p+1:p+m*p);

if showcond>0
    disp(['det  = ' num2str(det(covz))]);
    disp(['cond = ' num2str(cond(covz))]);
% there is no isdefinite() in matlab
%disp(['positive definite? ' num2str(isdefinite(covz))]);
end

Rb = -R(:,1+p:p+p*m)';        % nonhomogeneous item
Aall = (covz \ Rb)';          % solve all-jointed regression, covz * Aall' = Rb
Deps = R(1:p,1:p) - Aall*Rb;  % variance matrix of noise term

%save('-ascii','Aall.txt','Aall');    % save coefficient
%save('-ascii','Deps.txt','Deps');    % save noise term

if (p == 1)
    GC = 0;
    return ;
end

Depsj = zeros(p-1, p);           % echo column corresponding to a excluded variate
idx0 = 1:p:m*p;                  % indexes of variate to exclude
for k = 1 : p
    idx = true(1, m*p);          % the index of lines we want to solve
    idx(idx0) = false;
    idxb= idx(1:p);
    Rbj = Rb(idx, idxb);
    Acj = (covz(idx, idx) \ Rbj)';     % solve p-1 variates regression
    Depsj(:, k) = diag(R(idxb, idxb) - Acj*Rbj);
    idx0 = idx0 + 1;             % next variate
end

%Depsj(Depsj<0) = 0; % make sure diag are positive (TODO: Is there better idea to fix this?)

GC = zeros(p,p);
dd = diag(Deps);
dj = zeros(p,1);
for k = 1 : p
    dj(1:p-1) = Depsj(:, k);
    dj(k+1:end) = dj(k:p-1);
    dj(k) = dd(k);
    GC(:, k) = log(dj ./ dd);
end

end
