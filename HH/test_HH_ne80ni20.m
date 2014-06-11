%

clear('pm');  % make sure we are using a clean pm
pm.net  = 'net_100_01';
pm.nE   = 80;
pm.nI   = 20;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.10;
pm.scii = 0.10;
pm.pr   = 1.6;
pm.ps   = 0.04;
pm.t    = 1e6;   % 32sec(time cost) / 1.0sec(simulation)
pm.dt   = 1/32;
pm.stv  = 0.5;
pm.seed = 453;

[X, ISI, ras] = gen_HH(pm,'ext_T');

%exit

mode_IF = 'HH';
mode_ST = false;
GC_basic_info(X, 30, pm, mode_IF, mode_ST, ISI);

