

function [ssl, ssV] = sortEigenAbs(sl, sV)
  [~, sid] = sort(abs(sl), 'descend');
  ssl = sl(sid);
  ssV = sV(:,:,sid);
  es = 2*eps(max(abs(sl)));
  for k=2:length(ssl)
    if abs(real(ssl(k-1))-real(ssl(k))) < es &&...
       abs(imag(ssl(k-1))+imag(ssl(k))) < es
      if imag(ssl(k-1))<imag(ssl(k))
        disp('swaping eigen');
        tl = ssl(k-1);
        ssl(k-1) = ssl(k);
        ssl(k) = tl;
        tV = ssV(:,:,k-1);
        ssV(:,:,k-1) = ssV(:,:,k);
        ssV(:,:,k) = tV;
      end
    end
  end
