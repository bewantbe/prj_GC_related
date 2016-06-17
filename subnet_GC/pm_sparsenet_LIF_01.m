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

% the networks
neu_coor = bsxfun(@times, randMT19937(p, 2), [n_c*20, n_r*20]);  % unit: um
dis_mat = ...% 
sqrt( ...
  bsxfun(@minus, neu_coor(:, 1), neu_coor(:, 1)').^2 ...
+ bsxfun(@minus, neu_coor(:, 2), neu_coor(:, 2)').^2);

%1e4*exp(-dis_mat) ./ dis_mat;

net_connect = exp(-dis_mat/150) > randMT19937(size(dis_mat));
net_connect(eye(length(net_connect))==1) = 0;

pm.net = net_connect .* (1+0.1*randMT19937(size(net_connect)));
pm.nI  = 250;

pm.simu_method = 'SSC-Sparse';
pm.t    = 2e6;
pm.dt   = 1.0/32;
pm.stv  = 1.0;
pm.seed = 'auto';

