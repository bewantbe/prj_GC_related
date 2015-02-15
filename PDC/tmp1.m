%

v = [randn(1,100)];
a=toeplitz(v, v);
a = inv(a);
n = size(a, 1);
F = fft(eye(n));
ea = eig(a);
%fa = fft([v, fliplr(v(2:end))]);
fa = fft(v);

[~,sid] = sort(real(fa));
fa = fa(sid);

%plot(1:n, ea, 1:n, real(fa), 1:n, imag(fa))
plot(1:n, ea)
%bad!
