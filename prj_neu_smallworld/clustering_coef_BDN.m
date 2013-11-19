% calculate the clustering coefficient of binary directory network
% Giorgio Fagiolo, Phyrev E, 2007. Clustering in complex directed networks
%input: adjacency matrix

function [C_mean, C_BDN] = clustering_coef_BDN(A)

  n = size(A,1);
  A = 1*(A>0);                       % binary graph only
  A(eye(n)==1) = 0;                  % no self-interactions
  s_deg       = sum(A) + sum(A.');   % total degree
  s_deg_bidir = diag(A*A).';         % degree of bidirection edges
  C_BDN = 0.5*diag((A+A.')^3).' ./ (s_deg.*(s_deg-1) - 2*s_deg_bidir);
  C_BDN(s_deg<=1) = NaN;             % I have no idea how to define it
  %C_mean = mean(C_BDN(C_BDN>0));     % only count meanful points
  C_mean = sum(C_BDN(C_BDN>0))/n;

end
