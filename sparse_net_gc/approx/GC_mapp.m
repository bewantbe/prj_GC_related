% Give approximation of (conditional and pairwise) GC using coef

function [gc_mapp, b12_mapp, gc_pair_mapp] = GC_mapp(A2d, De, id_x, id_y)

  [p, m] = size(A2d);
  m = m/p;

  % Construct M and inverse G matrix
  A2d_I = [eye(p) A2d(:, 1:end-p)];
  invDe = inv(De);
  tic
  M = zeros(p*m, p*m);
  iG = sparse(p*m, p*m);
  for k=0:m-1
    M(k*p+1:(k+1)*p, k*p+1:end) = A2d_I(:,1:end-k*p);
    iG(k*p+1:(k+1)*p, k*p+1:(k+1)*p) = invDe;
  end

  % Blocked toeplitz matrix to toeplitz-block blocked matrix
  id_bt2tb = reshape(1:p*m, p, [])';
  M  = M (id_bt2tb, id_bt2tb);
  iG = iG(id_bt2tb, id_bt2tb);

  % index for indexing variates x,y,z
  id_bx = (1:m) + (id_x-1)*m;
  id_by = (1:m) + (id_y-1)*m;
  id_bz = 1:p*m;
  id_bz([id_bx id_by]) = [];

  a12 = -A2d(id_x, id_y:p:end);  % coef: id_y -> id_x

  % Conditional GC y -> x
  Qyy_mapp = M(:, id_by)'*iG*M(:, id_by);
  gc_mapp = a12 / Qyy_mapp * a12' / De(id_x,id_x);

  a13 = -M((id_x-1)*m+1, id_bz);
  a13 = reshape(circshift(reshape(a13,m,[]), -1), 1, []);
  Qzz_mapp = M(:, id_bz)'*iG*M(:, id_bz);  % most slow step
  Qzy_mapp = M(:, id_bz)'*iG*M(:, id_by);  % second most slow step
  a13_div_Qzz = a13 / Qzz_mapp;

  % pairwise GC coefficient y -> x
  b12_mapp = a12 - a13_div_Qzz * Qzy_mapp;

  % pairwise GC value y -> x
  Qyz_mapp = M(:, id_by)'*iG*M(:, id_bz);
  epsilon_1 = De(id_x,id_x) + a13_div_Qzz * a13';
  gc_pair_mapp = b12_mapp / (Qyy_mapp - Qyz_mapp/Qzz_mapp*Qzy_mapp) * b12_mapp' / epsilon_1;

