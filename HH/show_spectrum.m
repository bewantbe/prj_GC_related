% show spectrum of time series in dB scale

function show_spectrum(x1)

fftlen = lowest_smooth_number_exact(sqrt(length(x1)));
[sx, fqs] = mX2S_wnd(x1, [fftlen, 0.5], @(x)0.5+0.5*cos(2*pi*x));
fqs = fftshift(fqs);
sx  = fftshift(sx);
%plot(fqs, sx);
plot(fqs, 10*log10(abs(sx)));
%semilogy(fqs, sx);
xlim([0, 0.5]);
ylabel('dB');
