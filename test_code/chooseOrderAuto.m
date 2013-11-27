% Choose Order by AIC/BIC
% Stop when best order is found
% Use levinson algorithm, so not suitable to big condition number problem

function od = chooseOrderAuto(X, ic_mode, od_max)
if ~exist('od_max', 'var')
  od_max = 50;
end
if ~exist('ic_mode', 'var')
  ic_mode = 'BIC'
end

[p,len] = size(X);
X = bsxfun(@minus, X, mean(X,2));
Rxy0 = (X(:, od_max+1:len) * X(:, od_max-0+1:len-0)') / (len-od_max);
Rxy1 = (X(:, od_max+1:len) * X(:, od_max-1+1:len-1)') / (len-od_max);
R1 = Rxy1;
b_R1 = Rxy1';

af = - Rxy0 \ b_R1;
ab = - Rxy0 \ Rxy1;
df = Rxy0 + Rxy1 * af;
db = Rxy0 + b_R1 * ab;
s_det_de = det(df);

for k = 2:od_max
  Rxy = (X(:, od_max+1:len) * X(:, od_max-k+1:len-k)') / (len-od_max);
  ef = b_R1 * af + Rxy';
  b_R1 = [Rxy', b_R1];
  eb = R1 * ab + Rxy;
  R1 = [R1, Rxy];
  gf = db \ ef;
  gb = df \ eb;
  tmp_af = af;
  af = [tmp_af; zeros(p)] - [ab; eye(p)] * gf;
  ab = [zeros(p); ab] - [eye(p); tmp_af] * gb;
  df = df - eb * gf;
  db = db - ef * gb;
  s_det_de = [s_det_de, det(df)];
end

od = s_det_de;
