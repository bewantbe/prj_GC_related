% sum blocks of m*m
function arr = sumBlock(Q, m, p)
  arr = permute(reshape(Q, m, p, m, p), [1 3 2 4]);
  arr = squeeze(sum(reshape(abs(arr), m*m, p, p))) / m;
  %arr(eye(p)==1) = 0;
end

