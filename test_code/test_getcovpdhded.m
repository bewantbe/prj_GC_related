%

p = 10;
len = 1e5;
rand('state',1);
X = rand(p,len);

m = 100;

t_bg = m+1;     % time range in common
t_ed = len-m;
% head and tail parts
covz = zeros((m+1)*p,(m+1)*p);
t_ed = t_ed+1;
t_bg = t_bg-1;
m1 = m+1;
tic
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
    end
end
toc

t_bg = m+1;     % time range in common
t_ed = len-m;
tic
covz2 = getcovpdhded(X, t_bg, t_ed, m);
toc

fprintf('max abs err: %g\n', max(abs(covz2-covz)(:)));
