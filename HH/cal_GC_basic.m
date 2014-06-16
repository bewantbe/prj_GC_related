% get and save basic GC analysis results

test_HH_ne80ni20;  % 83.6 sec

use_od = chooseOrderAuto(X);              %   76.2 sec
Y = WhiteningFilter(X, use_od);           %  140.5 sec
%[so,ao]=chooseOrderFull(Y, 'AIC', 40);    % 1376.9 'AIC', 141.1 sec BIC
%GC_basic_info(Y, 30, pm, mode_IF, mode_ST, ISI, '_w');  %  87.4 sec
GC_basic_info(Y, 40, pm, mode_IF, mode_ST, ISI, '_w');  % 124.4 sec

[A, B] = custom_filters('butter_o=4_wc=0.1', true);
X_l = filter(B',A',X')';  %  3.1 sec
use_od = 27;
srd_l = WhiteningFilter(X_l, use_od, 'qr');  % 360.9 sec, od=20
GC_basic_info(srd_l, 40, pm, mode_IF, mode_ST, ISI, '_l_w');  % 123.8 sec


GC_basic_info(srd_l, 40, pm, mode_IF, mode_ST, ISI, '_cov_l_w'); % 1048 sec
GC_basic_info(Y, 40, pm, mode_IF, mode_ST, ISI, '_cov_w');       % 1048 sec



