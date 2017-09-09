%

function d = mulMats(a, b, c)
d = zeros(size(a));
for k = 1:size(a,3)
  d(:,:,k) = a(:,:,k) * b * c(:,:,k)';
end

