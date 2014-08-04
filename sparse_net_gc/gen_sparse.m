
function net = gen_sparse(p, sparseness, seed)
  s = rand('state');    % Note that this is incompatible with MATLAB !!
  rand('state', seed);
  net = rand(p) < sparseness;
  net(eye(p)==1) = 0;
  rand('state', s);
