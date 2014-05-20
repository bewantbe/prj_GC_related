% test EPSP, IPSP, Poisson EPSP

clear('pm');  % make sure we are using a clean pm
%pm.net  = 'net_2_2';
pm.net  = 'net_1_0';
pm.scee = 0.05;
pm.ps   = 2e-2;
pm.pr   = 2e-2/pm.ps;
pm.t    = 1e5;
pm.stv  = 0.5;
pm.seed = 3;
pm.extra_cmd = '-q';
%pm.ps_mul = [1 0];

[X, ISI, ras] = gen_HH(pm, 'new,rm');
X_rest = 0.000027756626542950875;
X = (X - X_rest)*10;  % convert to mV, shift to exact resting state
s_T = pm.stv*(1:length(X));

disp(['Firing freq. = ', mat2str(1000./ISI), ' Hz']);
size(X)
size(ras)

rgB = 8200/pm.stv;
rgL = 200;
rgE = rgB+rgL-1;
rgP = rgB:rgE;
rgS = pm.stv*(1:rgL);
figure(1);
plot(s_T, X);
%plot(rgS, X(2,rgP));

