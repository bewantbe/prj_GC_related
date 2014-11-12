%

function GC = nGrangerTfast(X, m, b_whiten_first)
  p = size(X, 1);
  if exist('b_whiten_first', 'var') && b_whiten_first ~= 0
    % whiten data can help reduce condition number
    switch b_whiten_first
    case 1
      % whiten time series data directly
      X = WhiteningFilter(X, m);  % whiten data
      covz = getcovzpd(X, m);
      [A2d, D] = ARregressionpd(covz, p);
    case 2
      % whiten the covariance in frequency domain
      fftlen = max(1024, 5*m);
      covz = getcovzpd(X, m);
      [A2d, D] = ARregressionpd(covz, p);
      S = A2S(A2d, D, fftlen);
      S = StdWhiteS(S);
      R = S2cov(S, m);
      covz = R2covz(R);
      [A2d, D] = ARregressionpd(covz, p);
    otherwise
      error('no this mode');
    end
  else
    R = getcovpd(X, m);
    covz = R2covz(R);
    [A2d, D] = ARregression(R);
    %covz = getcovzpd(X, m);
    %[A2d, D] = ARregressionpd(covz, p);
  end

  d = diag(D);
  Qz = inv(covz(p+1:end, p+1:end));

  a = reshape(-A2d, p,p,[]);
  a = permute(a, [3,1,2]);   % index: (time lag, i, j)  (j->i)

  id_0 = 0:p:p*m-1;

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
