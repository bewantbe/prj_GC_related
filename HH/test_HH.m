%

pm.net  = 'net_1_0';
pm.ps   = 0.04;
pm.pr   = 1.6;
pm.scee = 0.05;
pm.t    = 40;
pm.dt   = 2^-9;
pm.stv  = 0.5;

id_case = 2;
switch id_case
  case 0
    % N=1, zeros input
    pm.ps   = 0.00;
    pm.net = 'net_1_0';
    path_spe = 'spe0.txt';
    path_mathe = 'tb0.txt';
  case 1
    % N=1, poisson
    pm.net = 'net_1_0';
    path_spe = 'spe1.txt';
    path_mathe = 'tb1.txt';
  case 2
    % N=2, poisson
    pm.net = 'net_2_2';
    path_spe = 'spe2.txt';
    path_mathe = 'tb2.txt';
end

%pm.extra_cmd = sprintf('--save-poisson-events %s',path_spe);
pm.extra_cmd = sprintf('--RC-filter 0 1 --save-poisson-events %s',path_spe);
[X, ISI, ras] = gen_HH(pm);

rg_l = 80;
rg_b = 1;
rg_e = rg_b + rg_l - 1;

%fscaling = @(x) x*10-65;
fscaling = @(x) x*10;

X_e = load(path_mathe)';

figure(1);
plot(1:rg_l, fscaling(X(:,rg_b:rg_e)), '-o', 'markersize', 2,...
     1:rg_l, X_e(:,rg_b:rg_e), '-o', 'markersize', 2);
if id_case==2
  legend('rt-x','rt-y','ma-x','ma-y');
else
  legend('rt-x','ma-x');
end

figure(2);
plot(1:rg_l, fscaling(X(:,rg_b:rg_e)) - X_e(:,rg_b:rg_e), '-o', 'markersize', 2);
