% Calculate GC without explicitly do p-1 variable regressions
% Much faster than RGrangerT(R) for large variable case.

function GC = RGrangerTLevinson(R)
  % so R is 2d cov series
  p = size(R, 1);
  m = size(R, 2) / p - 1;
  %covz = R2covz(R);
  %[A2d, D] = ARregressionpd(covz, p);
  %Qz = inv(covz(p+1:end, p+1:end));
  [s_Qjj, A2d, D] = GetQyy(R);

  a = reshape(-A2d, p,p,[]);
  a = permute(a, [3,1,2]);   % index: (time_lag, i, j)  (j->i)
  d = diag(D);
  id_0 = 0:p:p*m-1;

  GC = zeros(p, p);
  for j = 1 : p
    GC(:, j) = log1p(sum(s_Qjj(:,:,j) \ a(:,:,j) .* a(:,:,j))' ./ d);
    GC(j, j) = 0;
  end
end
