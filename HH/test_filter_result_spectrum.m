% run after test_filter_result.m

fftlen = lowest_smooth_number_exact(sqrt(size(X,2)));
%f_wnd = @(x) 1;
%f_wnd = @(x) 1-2*abs(x);
f_wnd = @(x) 0.5+0.5*cos(2*pi*x);  % seems the best choice
%a = 8;
%f_wnd = @(x) besseli(0,pi*a*sqrt(1-(2*x).^2))/besseli(0,pi*a);
sX   = mX2S_wnd( bsxfun(@minus, X  , mean(X  ,2)), [fftlen, 0.5], f_wnd);
sX_l = mX2S_wnd( bsxfun(@minus, X_l, mean(X_l,2)), [fftlen, 0.5], f_wnd);
%stv = 0.5;  % ms
s_fq = (0:fftlen-1)/fftlen /stv*1000;  % Hz

use_od_sgcapp = 50;
gc_x   = getGCSapp(sX  , use_od_sgcapp)
gc_x_l = getGCSapp(sX_l, use_od_sgcapp)


fS2dB = @(x) 10*log10(abs(x));

figure(5);
h = plot(
  s_fq, fS2dB(sX(:,1,1)),...
  s_fq, fS2dB(sX(:,2,2)),...
  s_fq, fS2dB(sX(:,1,2)),...
  s_fq, fS2dB(sX_l(:,1,1)),...
  s_fq, fS2dB(sX_l(:,2,2)),...
  s_fq, fS2dB(sX_l(:,1,2))...
);
xlim([0 0.5*1000/stv]);

figure(6);
sX_w = StdWhiteS(sX);
sX_l_w = StdWhiteS(sX_l);
plot(
  s_fq, fS2dB(sX_w(:,1,1)),'color',get(h(1),'color'),...
  s_fq, fS2dB(sX_w(:,1,2)),'color',get(h(3),'color'),...
  s_fq, fS2dB(sX_l_w(:,1,2)),'color',get(h(6),'color')...
);
xlim([0 0.5*1000/stv]);
ylim([-40, 10]);
legend('sX_w(1,2)', 'sX_l_w(1,2)');

