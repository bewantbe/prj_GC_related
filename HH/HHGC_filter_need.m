% produce plots for paper
clear('pm');
pm.net  = 'net_2_2';
pm.scee = 0.05;
pm.pr   = 1.6;
pm.ps   = 0.04;
pm.t    = 1e6;
pm.stv  = 0.5;

% generate data
[X_o, ISI, ras] = gen_HH(pm, 'ext_T');
use_od = 50;
srd_o = WhiteningFilter(X_o, use_od);

% lowpassed data
[A, B] = custom_filters('butter_o=4_wc=0.1', true);
X_l = filter(B',A',X_o')';
use_od = 50;
srd_l = WhiteningFilter(X_l, use_od, 'qr');

% results about spectrum
fftlen = lowest_smooth_number_exact(sqrt(size(X_o,2)));
f_wnd = @(x) 0.5+0.5*cos(2*pi*x);  % seems the best choice
sX_o = mX2S_wnd( bsxfun(@minus, X_o, mean(X_o,2)), [fftlen, 0.5], f_wnd);
sX_l = mX2S_wnd( bsxfun(@minus, X_l, mean(X_l,2)), [fftlen, 0.5], f_wnd);
sfq = (0:fftlen-1)/fftlen /pm.stv*1000;  % Hz

% spectrum from AR regression
use_od = 50;
[A_o, De_o] = ARregressionpd(getcovzpd(X_o, use_od), size(X_o,1));
sAX_o = A2S_new(A_o, De_o, fftlen);
sAX_o = permute(sAX_o, [3 1 2]);
% TODO: Failed here, not a well posed problem
%[A_l, De_l] = ARregressionpd(getcovzpd(X_l, use_od), size(X_l,1));
%sAX_l = A2S_new(A_l, De_l, fftlen);
% single variable AR
use_od = 26;   % determined by chooseOrderAuto(X_l(1,:),'AIC',30)
a1s_l  = zeros(size(X_l,1), use_od);
sa1s_l = zeros(size(X_l,1), fftlen);
de1s_l = zeros(size(X_l,1), 1);
for id_neu = 1:size(X_l,1)
  [a, de] = ARregressionpd(getcovzpd(X_l(id_neu, :), use_od), 1);
  a1s_l(id_neu, :) = a;
  de1s_l(id_neu)   = de;
  sa1s_l(id_neu, :) = A2S_new(a, de, fftlen);
end

% frequency domain GC comparison
use_od_sgcapp = 50;
gc_sX_o = getGCSapp(sX_o, use_od_sgcapp)
gc_sX_l = getGCSapp(sX_l, use_od_sgcapp)

% show range in volt plot
rg_t_bg = 1.2e5;
ras_show_t = [rg_t_bg, rg_t_bg+100];  % time range to show ras
rg_l = floor((ras_show_t(2) - ras_show_t(1))/pm.stv);
rg_b = 1+floor(ras_show_t(1) / pm.stv);
rg_e = rg_b + rg_l - 1;
rg_ts = (rg_b:rg_e) * pm.stv;
rg_ts_rel = (1:rg_l) * pm.stv;

% list of firing event in this time range
ls_ras = ras(find(ras_show_t(1) <= ras(:, 2), 1) : ...
             find(ras_show_t(2) <  ras(:, 2), 1) - 1, :);
ls_ras(:, 2) = ls_ras(:, 2) - rg_t_bg;  % use ralative time label

%fscaling = @(x) x*10-65;
fscaling = @(x) x;

% show voltage trace
figure(1);
plot(rg_ts_rel, fscaling(X_o(:,rg_b:rg_e)));
%line([ls_ras(:, 2), ls_ras(:,2)]', [ls_ras(:,1), 0.9+ls_ras(:,1)]');
line([ls_ras(:, 2), ls_ras(:,2)]',...
     [zeros(size(ls_ras,1),1), ones(size(ls_ras,1),1)]');
xlabel('t/ms');

figure(2);
plot(rg_ts_rel, fscaling(srd_o(:,rg_b:rg_e)));
line([ls_ras(:, 2), ls_ras(:,2)]',...
     [zeros(size(ls_ras,1),1), ones(size(ls_ras,1),1)]');
xlabel('t/ms');

% show spectrum
fS2dB = @(x) 10*log10(abs(x));

figure(5);
h = plot(
  sfq, fS2dB(sX_o(:,1,1)),...
  sfq, fS2dB(sX_o(:,2,2)),...
  sfq, fS2dB(sX_o(:,1,2)),...
  sfq, fS2dB(sX_l(:,1,1)),...
  sfq, fS2dB(sX_l(:,2,2)),...
  sfq, fS2dB(sX_l(:,1,2)),...
  sfq, fS2dB(sa1s_l(1,:))
  %sfq, fS2dB(sAX_o(:,1,1))
);
xlim([0 0.5*1000/pm.stv]);
ylim([-140 20]);
xlabel('Freq. (Hz)');
ylabel('dB');
legend('s11','s22','s12','sl11','sl22','sl12', 'ARv1');

