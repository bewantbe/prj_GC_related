% Rearrange the order of correlations
% From block toeplitz to toeplitz blocks

function [Rvm, rvm] = covOrderMajor2VariableMajor(R, permvec)
  [p, m] = size(R);
  m = round(m/p)-1;
  covz = R2covz(R);

  id_rearrange = bsxfun(@plus, permvec(:), p*(0:m));
  covz = covz(id_rearrange, id_rearrange);

  Rvm = cell(3,3);
  rvm = cell(1,3);
  id_p = p:p:(p*(m+1)-1);
  id_p_3 = bsxfun(@plus, [3:p]', p*(1:m))(:).';
  Rvm{1,1} = covz(id_p+1, id_p+1);
  Rvm{1,2} = covz(id_p+1, id_p+2);
  Rvm{1,3} = covz(id_p+1, id_p_3);
  Rvm{2,1} = covz(id_p+2, id_p+1);
  Rvm{2,2} = covz(id_p+2, id_p+2);
  Rvm{2,3} = covz(id_p+2, id_p_3);
  Rvm{3,1} = covz(id_p_3, id_p+1);
  Rvm{3,2} = covz(id_p_3, id_p+2);
  Rvm{3,3} = covz(id_p_3, id_p_3);
  rvm{1,1} = covz(1, id_p+1);
  rvm{1,2} = covz(1, id_p+2);
  rvm{1,3} = covz(1, id_p_3);
end
