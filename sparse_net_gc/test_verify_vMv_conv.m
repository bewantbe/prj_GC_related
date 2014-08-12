%

m = 5;
%randn('state',1);
v = randn(1, m);
a = randn(1, m);
for k = 1:m
  A(:, k) = shift(a, k-1);
end
u = randn(1, m);

vf = fft(v);
uf = fft(u);
af = fft(a);

% time domain produce sum v.s. frequency domain product mean
v * u'
mean(vf .* conj(uf))

v * A * u'
mean(vf .* conj(af) .* conj(uf))

v * A^3 * u'
mean(vf .* conj(af).^3 .* conj(uf))

% Cool!!
v * inv(A) * u'
mean(vf .* conj(af).^(-1) .* conj(uf))
