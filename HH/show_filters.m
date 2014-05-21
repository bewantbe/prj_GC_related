% test lowpass filter
fS2dB = @(x) 10*log10(abs(x));

%[A, B] = custom_filters(1, true);
[A, B] = custom_filters('butter_o=5_wc=0.25', true);

x=randn(1,1e7);
y=filter(B,A,x); %conventional filtering

fftlen = 1024;
fftlen = 4096;
%                            % fftlen    4096      1024
%f_wnd = @(x) 1;                      % -45 dB      -39dB
%f_wnd = @(x) 1 - 2*abs(x);           % -119 dB     -101dB
f_wnd = @(x) 0.5+0.5*cos(2*pi*x);    % -176 dB     -146dB
%a = 8;                               % -233 dB     -228dB
%f_wnd = @(x) besseli(0,pi*a*sqrt(1-(2*x).^2))/besseli(0,pi*a);
sy = mX2S_wnd(y, [fftlen, 0.5], f_wnd);
s = filterAB2S(A, B, 1, fftlen);  % the theoretical result

stv = 0.5;  % ms
s_fq = (0:fftlen-1)/fftlen /stv*1000;  % Hz

%figure(1);
%plot(s_fq, sx);

figure(2);
plot(s_fq, sy, s_fq, s);
axis([0 s_fq(fftlen/2) 0 1.2]);
%axis([200 300 0 1.2]);

figure(3);
%semilogy(s_fq, sy, s_fq, s);
plot(s_fq, fS2dB(sy), s_fq, fS2dB(s));
%axis([0 s_fq(fftlen/2) 1e-4 2]);
xlim([0 s_fq(fftlen/2)]);
ylim([-300, 50]);
ylabel('dB');

