% Matrix multiply the first two dimension, loop over all other dimensions

function z = mult3d(a, b, c)
  f_n = @(x) numel(x) / (size(x, 1)*size(x,2));
  n = f_n(a);
  if n ~= f_n(b) || exist('c','var') && n ~= f_n(c)
    error('nonconformant operand size');
  end
  if exist('c','var')
    z = zeros(size(a, 1), size(c, 2), n);
    for k = 1 : n
      z(:,:,k) = a(:,:,k) * b(:,:,k) * c(:,:,k);
    end
  else
    z = zeros(size(a, 1), size(b, 2), n);
    for k = 1 : n
      z(:,:,k) = a(:,:,k) * b(:,:,k);
    end
  end
end
