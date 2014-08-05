
function net = gen_sparse(p, sparseness, seed)
  s = rand('state');    % Note that this is incompatible with MATLAB !!
  if isstruct(p)
    sparseness = p.sparseness;
    seed       = p.seed;
    p          = p.p;
  end
  rand('state', seed);
  net = rand(p) < sparseness;
  net(eye(p)==1) = 0;
  rand('state', s);
