% 

addpath('/home/xyy/matcode/GC_clean/GCcal/');
maxabs = @(x) max(abs(x(:)));

len = 1e4;
X = gdata(len, 2, 3);

od0 = 30;
fftlen = 512;
p = size(X, 1);
R = getcovpd(X, od0);
[Aall, Deps] = ARregression(R);
[Sp, fqs] = A2S(Aall, Deps, fftlen);

% Verify the paper
% Directed transfer functions
Aw = fft(reshape([eye(p) Aall], p, p, []), fftlen, 3);
S = invMats(Aw);

figure(1);
plot(fqs, real(Sp(1,2,:)(:)), fqs, imag(Sp(1,2,:)(:)))
xlim([-0.5,0.5])

% Cross spectrum, should be the same as Sp
gw = mulMats(S, Deps, S);
maxabs(Sp-gw)

figure(2);
plot(fqs, real(gw(1,2,:)(:)), fqs, imag(gw(1,2,:)(:)))
xlim([-0.5,0.5])

Gij = zeros(p,p,fftlen);
for i = 1:p
  for j = 1:p
    if i == j
      continue
    end
    Gij(i,j,:) = -log(1 - (Deps(j,j) - Deps(i,j)^2/Deps(i,i)) * real(S(i,j,:) .* conj(S(i,j,:)))(:) ./ real(gw(i,i,:)(:)));
  end
end

wGC = nGrangerF(X, [od0 od0], fftlen);

GC = RGrangerT(R)
mean(wGC,3)
mean(Gij,3)

figure(3);
plot(fqs, Gij(i,j,:)(:), fqs, wGC(i,j,:)(:))
xlim([-0.5,0.5])

