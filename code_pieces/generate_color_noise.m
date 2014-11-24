% 

r = [1 0.5 0.25 0 0 0 0 0 0 0 0 0 0 0];  % covariances
[a,d] = ARregression(r);

% check the covariances
fft_len = 1024;
af = fft([1 a], 1024);
s = d ./(af .* conj(af));
r = real(ifft(s, fft_len));
plot(r, '-o');  xlim([0,20]);

% 
len = 1e6;
w = randn(1, len);
x = filter(sqrt(d), [1 a], w);

% check again
rr = getcovpd(x, 19); figure(2); plot(rr, '-o');

