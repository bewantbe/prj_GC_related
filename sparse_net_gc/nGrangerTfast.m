%

function GC = nGrangerTfast(X, m)

  if exist('wcov', 'var')
    % whiten the covariance (reduce condition number)
    %[A2d, D] = ARregressionpd(covz);
    %fftlen = max(1024, 5*m);
    %S = A2S(A2d, D, fftlen);
    %S = StdWhiteS(S);
    %R = S2cov(S, m);
    %covz = getcovzpd(X, m);
    %[A2d, D] = ARregressionpd(covz);
  else
    % whiten original data
    p = size(X, 1);
    %X = WhiteningFilter(X, m);  % whiten data, reduce condition number
    %covz = getcovzpd(X, m);
    %[A2d, D] = ARregressionpd(covz, p);
    R = getcovpd(X, m);
    covz = R2covz(R);
    [A2d, D] = ARregression(R);
  end

  a = reshape(-A2d, p,p,[]);
  a = permute(a, [3,1,2]);   % index: time lag, i, j  (j->i)

  d = diag(D);
  Qz = inv(covz(p+1:end, p+1:end));
  id_0 = 0:p:p*m-1;
  %disp('-- begin RGrangerT --');
  %RGrangerT(R)
  %disp('-- end RGrangerT --');

  covz_orig = covz;
  permvec0 = 1 : p;
  GC = zeros(p, p);
  for j = 1 : p
    Qjj = Qz(id_0+j, id_0+j);
    for i = 1 : p
      if i ~= j
        var_reduce = a(:,i,j)' / Qjj * a(:,i,j);
        GC(i,j) = log1p(var_reduce / d(i));
      end
    end
  end
end
