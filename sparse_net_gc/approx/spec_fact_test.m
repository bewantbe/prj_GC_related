%

gen_data_n10_c1;
X = bsxfun(@minus, X, mean(X,2));

% calculate spectrum by Welch's method
fftlen = 1024;
f_wnd = @(x) 1 - 2*abs(x);
%f_wnd = @(x) 1;
tic; S_ws = mX2S_wnd(X, [fftlen 0.5], f_wnd); toc
fqs_ws = (1:fftlen/2)/fftlen;

% calculate spectrum by multitaper
fftlen = 2048;
nHBW = 20;
n_taper = 10;
tic; S_mt = mX2S_mt(X, [fftlen 0.5], nHBW, n_taper); toc
fqs_mt = (1:fftlen/2)/fftlen;

figure(15);
semilogy(fqs_ws, abs(S_ws(1:end/2,1,2)), fqs_mt, abs(S_mt(1:end/2,1,2)));

figure(12);
plot(fqs_ws, S_ws(1:end/2,1,1), fqs_mt, S_mt(1:end/2,1,1));
figure(13);
semilogy(fqs_ws, S_ws(1:end/2,1,1), fqs_mt, S_mt(1:end/2,1,1));



%return;

use_od = 50;

gc=nGrangerTfast(X, use_od);
figure(1); imagesc(gc/0.001); caxis([0 1]); colorbar()

%R = ifft(S, [], 3);
%R = reshape(real(R(:,:,1:use_od+1)), p, []);
%gc_r=RGrangerTfast(R);
%figure(3); imagesc(gc_r/0.001); caxis([0 1]); colorbar()

S = S_ws;
S = permute(S, [2 3 1]);
%save('-v7', 'S_test1.mat', 'S', 'pm')

tic; gc_s=SGrangerT(S, use_od); toc
figure(2); imagesc(gc_s/0.001); caxis([0 1]); colorbar()

figure(6);
%plot(gc(eye(p)==0)/0.001, gc_s(eye(p)==0)/0.001, 'o', [0 1], [0 1]);
plot(gc(eye(p)==0)/0.001, (gc_s(eye(p)==0)-gc(eye(p)==0))/0.001, 'o');
ylim([-1 1]*0.02);

