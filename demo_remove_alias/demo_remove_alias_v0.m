% Demo of removing bias that is due to aliases(folding) in DFT approximatly.
% Work well when peak is in low frequncy

n = 1e6;
b = 0.5;  % angular frequency (0~pi, better <1)
a = 0.4;  % strength of Gaussian white
T = 1:n;
phi = b*T + a*cumsum(randn(1,n));
X = sin(phi);

figure(1);
plot(T(1:100),X(1:100));

m = 512;  % size of each slice
mX = reshape(X(1:m*floor(n/m)),1,m,floor(n/m));
[aveS, fqs] = mX2S_ft(mX);
fqs = fftshift(fqs)/m;    % order suitable for plot
aveS = fftshift(aveS)';

% remove bias
df1 = @(w) 1./(2*(1-cos(w))) - 1./w.^2;
c = mean(aveS(end-2:end)) * (1-4/pi/pi) / df1(pi);
aveS_removed_alias_app = aveS - c*df1(fqs*2*pi);

figure(2);
plot(fqs, aveS, fqs, aveS_removed_alias_app);
xlim([-0.5,0.5]);
ylim([0,2*c]);

figure(3);
rg = ceil(length(fqs)/2)+2 : length(fqs);
h_fqs  = fqs (rg);
h_aveS = aveS(rg);
h_aveS_fix = aveS_removed_alias_app(rg);
higher_freq = linspace(0.5,1,100);
higher_s    = c./(2*pi*higher_freq).^2;
loglog(h_fqs, h_aveS, h_fqs, h_aveS_fix, higher_freq, higher_s);

