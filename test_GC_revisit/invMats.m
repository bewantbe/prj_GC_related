%

function A = invMats(a)
A = zeros(size(a));
for k = 1:size(a,3)
  A(:,:,k) = inv(a(:,:,k));
end

