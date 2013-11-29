%
% Mean value of X must be subtracted.

function covz = getcovzFromRpd(X, R, m)
[p, len] = size(X);
if p~=size(R,1)
  error('wrong paire of X R');
end
m_R = round(size(R,2)/p)-1;
if m_R < m
  error('Order of R is too low');
end
% Here assume R is obtained by
% R = getcovpd(X, m_R);

t_bg = m+1;     % time range in common
t_ed = len-m;
% middle part
R  = (len-m_R) * R;
RR = zeros(p, (2*m+1)*p);
for k = 0 : m
    R_hd = X(:, t_bg:m_R) * X(:, t_bg-k:m_R-k)';
    R_ed = X(:, t_ed+1:len) * X(:, t_ed+1-k:len-k)';
    R_k = R(:,k*p+1:(k+1)*p) + (R_hd - R_ed);
    RR(:, (m+k)*p+1 : (m+1+k)*p) = R_k;
    RR(:, (m-k)*p+1 : (m+1-k)*p) = R_k';
end
% head and tail parts
covz = zeros((m+1)*p,(m+1)*p);
t_ed = t_ed+1;
t_bg = t_bg-1;
m1 = m+1;
for i1=0:m
    for i2=0:m
        k=i2-i1;
        if (k>=0)
            covz(i1*p+1:(i1+1)*p, i2*p+1:(i2+1)*p) =...
              X(:,m1-i1:t_bg)*X(:,m1-i2:t_bg-k)'...
            + X(:,t_ed:len-i1)*X(:,t_ed-k:len-i2)';
        else
            covz(i1*p+1:(i1+1)*p, i2*p+1:(i2+1)*p) =...
              X(:,m1-i1:t_bg+k)*X(:,m1-i2:t_bg)'...
            + X(:,t_ed+k:len-i1)*X(:,t_ed:len-i2)';
        end
        %covz(i1*p+1:(i1+1)*p, i2*p+1:(i2+1)*p) =...  % this one is 10% slower
          %X(:,m1-i1:t_bg+k*(k<0))*X(:,m1-i2:t_bg-k*(k>0))'...
        %+ X(:,t_ed+k*(k<0):len-i1)*X(:,t_ed-k*(k>0):len-i2)';
    end
end
% combine them
for k=0:m
    covz(k*p+1:(k+1)*p,:) = covz(k*p+1:(k+1)*p,:) + RR(:,(m-k)*p+1:(2*m+1-k)*p);
end
covz = covz/(len-m);
