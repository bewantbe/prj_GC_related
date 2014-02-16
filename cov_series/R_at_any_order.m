% see SolveARrecursion.m

function s_R = R_at_any_order(s_lambda, s_V, s_od)
  [~,p,mp] = size(s_V);
  s_R = zeros(p,p,length(s_od));
  for k=1:length(s_od)
    B = zeros(p,p);
    od = s_od(k);
    for j=1:mp
      B = B + s_lambda(j)^od * s_V(:,:,j);
    end
    %B=real(sum(bsxfun(@mtimes,permute(s_lambda.^k,[1,3,2]),s_V),3));
    s_R(:,:,k) = real(B);
  end
end
