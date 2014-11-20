% Calculate GC without explicitly do p-1 variable regressions
% Do regression by Levinson method (Toeplitz)
% Much faster than RGrangerT(R) for large variables case.
% Significantly faster than RGrangerTfast(R) for large variables case

function GC = RGrangerTLevinson(R)
  [s_Qjj, A, D] = GetQyy(R);

  p = size(R, 1);
  A = reshape(-A, p,p,[]);  % index: (i, j, time_lag)
  A = permute(A, [3,1,2]);  % index: (time_lag, i, j)  (j->i)
  d = diag(D);

  GC = zeros(p, p);
  for j = 1 : p
    GC(:, j) = log1p(sum(s_Qjj(:,:,j) \ A(:,:,j) .* A(:,:,j))' ./ d);
    GC(j, j) = 0;
  end
end
