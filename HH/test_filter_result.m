%
% run analyse_GC_simple_HH.m first

% show volt and srd samples
rg_l = 100;
rg_b = 1e5;
rg_e = rg_b + rg_l - 1;

od = 50;
srd = WhiteningFilter(X, od);
fscaling = @(x) x*10-65;
%fscaling = @(x) x;

figure(1);
plot(1:rg_l, fscaling(X(:,rg_b:rg_e)));

figure(2);
plot(1:rg_l, fscaling(srd(:,rg_b:rg_e)));

[A, B] = custom_filters('butter_o=4_wc=0.1', true);
%[A, B] = custom_filters(11, true);
X_l = filter(B',A',X')'; %conventional filtering
%od_l = chooseOrderAuto(X_l, 'BIC', 100);
od_l = 50;
srd_l = WhiteningFilter(X_l, od_l, 'qr'); % better result, but much slower
%srd_l = WhiteningFilter(X_l, od_l);

figure(3);
plot(1:rg_l, fscaling(X_l(:,rg_b:rg_e)));

figure(4);
plot(1:rg_l, fscaling(srd_l(:,rg_b:rg_e)));

gc_X   = pos_nGrangerT2(X  , bic_od)
gc_srd = pos_nGrangerT2(srd, bic_od)

gc_X_l   = pos_nGrangerT2(X_l  , bic_od)
gc_src_l = pos_nGrangerT2(srd_l, bic_od)

fftlen = 1024;
f_wnd = @(x) 0.5+0.5*cos(2*pi*x);
sX   = mX2S_wnd( bsxfun(@minus, X  , mean(X  ,2)), [fftlen, 0.5], f_wnd);
sX_l = mX2S_wnd( bsxfun(@minus, X_l, mean(X_l,2)), [fftlen, 0.5], f_wnd);
%stv = 0.5;  % ms
s_fq = (0:fftlen-1)/fftlen /stv*1000;  % Hz


fS2dB = @(x) 10*log10(abs(x));

figure(5);
plot(s_fq, fS2dB(sX), s_fq, fS2dB(sX_l));
xlim([0 1000]);

use_od_sgcapp = 50;
gc_x   = getGCSapp(sX  , use_od_sgcapp)
gc_x_l = getGCSapp(sX_l, use_od_sgcapp)

figure(6);
sX_w = StdWhiteS(sX);
plot(
  s_fq, fS2dB(sX_w(:,1,1)),...
  s_fq, fS2dB(sX_w(:,1,2)),...
  s_fq, fS2dB(sX_l_w(:,1,2))...
);
xlim([0 1000]);
ylim([-40, 10]);
legend('sX_w(1,2)', 'sX_l_w(1,2)');

