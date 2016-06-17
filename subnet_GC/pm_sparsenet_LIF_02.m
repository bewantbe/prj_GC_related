%

pm = [];
pm.prog_path = '/home/xyy/code/point-neuron-network-simulator/bin/gen_neu';

pm.neuron_model = 'LIF-GH';
PSP = neu_psp_test(pm);
pm.scee = 0.12 * PSP.mV_scee;
pm.scie = 0.12 * PSP.mV_scee;
pm.scei = 0.2 * PSP.mV_scei;
pm.scii = 0.2 * PSP.mV_scei;
pm.pr   = 2.0;
pm.ps   = 0.4 * PSP.mV_ps;

randMT19937('seed', [12 3 3]);

n_r = 30;  % number of row (y)
n_c = 30;  % number of column (x)
p = n_r * n_c;

net_connect = randMT19937(p) < 0.2;
net_connect(eye(p)==1) = 0;

pm.net = net_connect;
pm.nI  = 250;

pm.simu_method = 'SSC-Sparse';
pm.t    = 2e6;
pm.dt   = 1.0/32;
pm.stv  = 1.0;
pm.seed = 'auto';

