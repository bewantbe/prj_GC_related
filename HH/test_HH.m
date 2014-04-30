%

pm.net  = 'net_1_0';
pm.ps   = 0.04;
%pm.ps   = 0.00;
pm.pr   = 1.6;
pm.scee = 0.05;
pm.t    = 40;
pm.dt   = 2^-9;
pm.stv  = 0.5;
pm.extra_cmd = ['--save-poisson-events spe.txt'];

[X, ISI, ras] = gen_HH(pm);

rg_l = 80;
rg_b = 1;
rg_e = rg_b + rg_l - 1;

%fscaling = @(x) x*10-65;
fscaling = @(x) x*10;

X_e = load('tb.txt')';

figure(1);
plot(1:rg_l, fscaling(X(:,rg_b:rg_e)), '-o', 'markersize', 2,...
     1:rg_l, X_e(:,rg_b:rg_e), '-o', 'markersize', 2);

figure(2);
plot(1:rg_l, fscaling(X(:,rg_b:rg_e)) - X_e(:,rg_b:rg_e), '-o', 'markersize', 2);

% passed:
% N=1, zeros input

% N=1, poisson
