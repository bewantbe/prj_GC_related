%
maxerr = @(x) max(abs(x(:)));

fftlen = 32;
od = 10;
r = zeros(1, fftlen);
rd = randn(1,od);
r(2:od+1) = rd;
r(end-od+1:end) = fliplr(rd);
r(1) = 10;

s = fft(r, fftlen);
if any(abs(imag(s)) > 1e-13)
  error('Hey!');
end
s = real(s);

figure(1);
plot(s);


#u = fft([r(1:2:end/2) zeros(1, fftlen/2) r(end/2+1:2:end)], fftlen);
#v = fft([r(end) r(2:2:end/2) zeros(1, fftlen/2-1) r(end/2+2:2:end)], fftlen);

u = fft(r(1:2:end));
v = fft([r(end) r(2:2:end-1)]);

maxerr(0.5*(s(1:end/2) + s((1:end/2)+end/2)) - u)
maxerr(0.5*((s(1:end/2) - s((1:end/2)+end/2)) .* exp(-1i*2*pi*(0:fftlen/2-1)/fftlen)) - v)

v2 = fft(r(2:2:end));
maxerr(0.5*((s(1:end/2) - s((1:end/2)+end/2)) .* exp(1i*2*pi*(0:fftlen/2-1)/fftlen)) - v2)

