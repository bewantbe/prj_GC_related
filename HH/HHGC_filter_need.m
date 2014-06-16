% produce plots for paper
clear('pm');
pm.net  = 'net_2_2';
pm.scee = 0.05;
pm.pr   = 1.6;
pm.ps   = 0.04;
pm.t    = 1e6;
pm.stv  = 0.5;

% Generate data
[X, ISI, ras] = gen_HH(pm, 'ext_T');

% Lowpassed data
[A, B] = custom_filters('butter_o=4_wc=0.1', true);
Y = filter(B',A',X')';

% Try to eliminate zeros in spectrum
lowpass_zero = 1-1.15e-3;
Z = Y;
for k=1:4
  Z = filter(1, [1 lowpass_zero], Z')';
end

% Time domain whiten
disp('Time domain whiten');  fflush(stdout);
use_od = 50;
Xw = zscore(WhiteningFilter(X, use_od), 2);
Yw = zscore(WhiteningFilter(Y, use_od, 'qr'), 2);  % cost a lots memory and time
Zw = zscore(WhiteningFilter(Z, use_od), 2);

% Get spectrum (non-parametric)
disp('Get spectrum (non-parametric)');  fflush(stdout);
fftlen = lowest_smooth_number_exact(sqrt(size(X,2)));
sfq = (0:fftlen-1)/fftlen /pm.stv*1000;  % Hz
f_wnd = @(x) 0.5+0.5*cos(2*pi*x);  % seems the best choice
fspec = @(x) mX2S_wnd( bsxfun(@minus, x, mean(x,2)), [fftlen, 0.5], f_wnd);
sX  = fspec(X);
sY  = fspec(Y);
sZ  = fspec(Z);
sXw = fspec(Xw);
sYw = fspec(Yw);
sZw = fspec(Zw);

% Get spectrum from AR regression
disp('Get spectrum from AR regression');  fflush(stdout);
use_od = 50;
[A_o, De_o] = ARregressionpd(getcovzpd(X, use_od), size(X,1));
sAX_o = A2S_new(A_o, De_o, fftlen);
sAX_o = permute(sAX_o, [3 1 2]);
% TODO: Failed here, not a well posed problem
%[A_l, De_l] = ARregressionpd(getcovzpd(Y, use_od), size(Y,1));
%sAX_l = A2S_new(A_l, De_l, fftlen);
% single variable AR
use_od = 26;   % determined by chooseOrderAuto(Y(1,:),'AIC',30)
a1s_l  = zeros(size(Y,1), use_od);
sa1s_l = zeros(size(Y,1), fftlen);
de1s_l = zeros(size(Y,1), 1);
for id_neu = 1:size(Y,1)
  [a, de] = ARregressionpd(getcovzpd(Y(id_neu, :), use_od), 1);
  a1s_l(id_neu, :) = a;
  de1s_l(id_neu)   = de;
  sa1s_l(id_neu, :) = A2S_new(a, de, fftlen);
end

% Time domain GC
disp('Time domain GC');  fflush(stdout);
use_od_gcT = 48;  % from chooseOrderAuto(X)
gc_X = nGrangerT(X, use_od_gcT)
use_od_gcT = 27;  % from chooseOrderAuto(X)
gc_Y = pos_nGrangerT2(Y, use_od_gcT)
use_od_gcT = 43;  % from chooseOrderAuto(X)
gc_Z = pos_nGrangerT2(Z, use_od_gcT)

% Frequency domain GC
disp('Frequency domain GC');  fflush(stdout);
use_od_sgcapp = 50;
gc_sX = getGCSapp(sX, use_od_sgcapp)
gc_sY = getGCSapp(sY, use_od_sgcapp)
gc_sZ = getGCSapp(sZ, use_od_sgcapp)
gc_sXw = getGCSapp(sXw, use_od_sgcapp)
gc_sYw = getGCSapp(sYw, use_od_sgcapp)
gc_sZw = getGCSapp(sZw, use_od_sgcapp)


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
plot(rg_ts_rel, fscaling(X(:,rg_b:rg_e)));
%line([ls_ras(:, 2), ls_ras(:,2)]', [ls_ras(:,1), 0.9+ls_ras(:,1)]');
line([ls_ras(:, 2), ls_ras(:,2)]',...
     [zeros(size(ls_ras,1),1), ones(size(ls_ras,1),1)]');
xlabel('t/ms');

figure(2);
plot(rg_ts_rel, fscaling(Xw(:,rg_b:rg_e)));
line([ls_ras(:, 2), ls_ras(:,2)]',...
     [zeros(size(ls_ras,1),1), ones(size(ls_ras,1),1)]');
xlabel('t/ms');

% show spectrum
fS2dB = @(x) 10*log10(abs(x));

figure(3);
h = plot(
  sfq, fS2dB(sXw(:,1,1)),'-b',...
  sfq, fS2dB(sXw(:,1,2)),'-b',...
  sfq, fS2dB(sYw(:,1,2)),'-r',...
  sfq, fS2dB(sZw(:,1,2)),'-k'...
);
xlim([0 0.5*1000/pm.stv]);
ylim([-40 10]);
xlabel('Freq. (Hz)');
ylabel('dB');
legend('sXw11','sXw12','sYw12','sZw12','location','southwest');

wsX = StdWhiteS(sX);
wsY = StdWhiteS(sY);
wsZ = StdWhiteS(sZ);

figure(4);
h = plot(
  sfq, fS2dB(wsX(:,1,1)),'-b',...
  sfq, fS2dB(wsX(:,1,2)),'-b',...
  sfq, fS2dB(wsY(:,1,2)),'-r',...
  sfq, fS2dB(wsZ(:,1,2)),'-k'...
);
xlim([0 0.5*1000/pm.stv]);
ylim([-40 10]);
xlabel('Freq. (Hz)');
ylabel('dB');
legend('wsX11','wsX12','wsY12','wsZ12','location','southwest');

figure(5);
h = plot(
  sfq, fS2dB(sX(:,1,1)),'-b',...
  sfq, fS2dB(sX(:,2,2)),'-b',...
  sfq, fS2dB(sX(:,1,2)),'-b',...
  sfq, fS2dB(sY(:,1,1)),'-r',...
  sfq, fS2dB(sY(:,2,2)),'-r',...
  sfq, fS2dB(sY(:,1,2)),'-r',...
  sfq, fS2dB(sZ(:,1,1)),'-k',...
  sfq, fS2dB(sZ(:,2,2)),'-k',...
  sfq, fS2dB(sZ(:,1,2)),'-k',...
  sfq, fS2dB(sa1s_l(1,:)), '-g'
  %sfq, fS2dB(sAX_o(:,1,1))
);
xlim([0 0.5*1000/pm.stv]);
ylim([-140 20]);
xlabel('Freq. (Hz)');
ylabel('dB');
legend('sX11','sX22','sX12','sY11','sY22','sY12','sZ11','sZ22','sZ12', 'ARv1','location','southwest');
