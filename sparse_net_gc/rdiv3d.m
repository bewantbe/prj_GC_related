% Matrix right divide use the first two dimension.
% Will loop over all other dimensions.
% Essentially a broadcasting version of mrdivide()

function z = rdiv3d(a, b, c)
  f_n = @(x) numel(x) / (size(x, 1)*size(x,2));
  n = max( f_n(a), f_n(b) );
  if (n ~= f_n(a) && f_n(a)~=1) || (n ~= f_n(b) && f_n(b)~=1)...
     || exist('c','var') && n ~= f_n(c)
    error('nonconformant operand size');
  end
  if exist('c','var')
    z = zeros(size(a, 1), size(c, 2), n);
    if f_n(b) > 1
      for k = 1 : n
        z(:,:,k) = a(:,:,k) / b(:,:,k) * c(:,:,k);
      end
    else
      for k = 1 : n
        z(:,:,k) = a(:,:,k) / b * c(:,:,k);
      end
    end
  else
    z = zeros(size(a, 1), size(b, 2), n);
    if f_n(b) > 1
      if f_n(a) > 1
        for k = 1 : n
          z(:,:,k) = a(:,:,k) / b(:,:,k);
        end
      else
        for k = 1 : n
          z(:,:,k) = a / b(:,:,k);
        end
      end
    else
      for k = 1 : n
        z(:,:,k) = a(:,:,k) / b;
      end
    end
  end
end
