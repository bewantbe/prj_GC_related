% test lowpass filter

%[A, B] = custom_filters(1, true);
[A, B] = custom_filters('butter_o=5_wc=0.25', true);

x=randn(1,1e7);
y=filter(B,A,x); %conventional filtering

fftlen = 1024;
fftlen = 4096;
%sx = X2Sxx(x, fftlen);
sy = X2Sxx(y, fftlen);
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
semilogy(s_fq, sy, s_fq, s);
%axis([0 s_fq(fftlen/2) 1e-4 2]);
xlim([0 s_fq(fftlen/2)]);

