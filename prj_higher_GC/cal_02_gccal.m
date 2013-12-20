
function g = cal_02_gccal(X, od)
  if ~exist('od','var') || isempty(od)
    od = chooseOrderAuto(X);
  end
  gc = pos_nGrangerT2(X,od);
  g.gc = gc;
  g.od = od;
  [g.p g.len] = size(X);
end
