% generate common data set
% need also /home/xyy/matcode/libs/myif.m

run('/home/xyy/matcode/GC_clean/startup.m');
addpath('/home/xyy/matcode/prj_GC_clean/HH');
addpath('/home/xyy/matcode/prj_GC_clean/sparse_net_gc');  % need gen_sparse.m


data_dir_prefix = '/home/xyy/matcode/prj_GC_clean/data/';   % don't forget to include the tailing slash (since it's a prefix)
T = 1e6;

if exist('id','var') && id == 1

% most "studied" case, 20% connectivity, E
pm = [];              % a new parameter set
pm.neuron_model = 'LIF_icc';  % program to run, with prefix raster_tuning_
pm.net  = 'net_100_01';  % can also be a connectivity matrix of full file path
pm.nI   = 0;          % default: 0. Number of Inhibitory neurons.
pm.scee = 0.005;
pm.scie = 0.00;       % default: 0. Strength from Ex. to In.
pm.scei = 0.00;       % default: 0. Strength from In. to Ex.
pm.scii = 0.00;       % default: 0.
pm.pr   = 0.24;
pm.ps   = 0.02;
pm.t    = T;
pm.dt   = 1.0/32;     % default: 1/32
pm.stv  = 0.5;        % default: 0.5
pm.seed = 'auto';     % default: 'auto'(or []). Accept integers
pm.extra_cmd = '';    % default: '--RC-filter 0 1'
gen_HH(pm, 'new,ext_T', data_dir_prefix);

% 60% connectivity, EI, should be bad
pm = [];
pm.neuron_model = 'LIF_icc';
pm.net  = 'net_100_20';
pm.nI   = 20;
pm.scee = 0.005;
pm.scie = 0.005;
pm.scei = 0.007;
pm.scii = 0.007;
pm.pr   = 1.00;
pm.ps   = 0.012;
pm.t    = T;
pm.dt   = 1.0/32;
pm.stv  = 0.5;
gen_HH(pm, 'new,ext_T', data_dir_prefix);

% 5.3% connectivity, EI
pm = [];
pm.neuron_model = 'LIF_icc';
pm.net  = 'net_100_21';
pm.nI   = 20;
pm.scee = 0.004;
pm.scie = 0.004;
pm.scei = 0.008;
pm.scii = 0.008;
pm.pr   = 1.00;
pm.ps   = 0.012;
pm.t    = T;
pm.dt   = 1.0/32;
pm.stv  = 0.5;
gen_HH(pm, 'new,ext_T', data_dir_prefix);

end
if exist('id','var') && id == 2

% small world, E
pm = [];
pm.neuron_model = 'LIF_icc';
pm.net  = 'net_100_rs01';
pm.nI   = 0;
pm.scee = 0.005;
pm.pr   = 1.00;
pm.ps   = 0.012;
pm.t    = T;
pm.dt   = 1.0/32;
pm.stv  = 0.5;
gen_HH(pm, 'new,ext_T', data_dir_prefix);

% small world, EI
pm = [];
pm.neuron_model = 'LIF_icc';
pm.net  = 'net_100_rs01';
pm.nI   = 20;
pm.scee = 0.005;
pm.scie = 0.005;
pm.scei = 0.007;
pm.scii = 0.007;
pm.pr   = 1.00;
pm.ps   = 0.012;
pm.t    = T;
pm.dt   = 1.0/32;
pm.stv  = 0.5;
gen_HH(pm, 'new,ext_T', data_dir_prefix);

end

%% Used for sparsity study
% common parameters for network
net_param.generator  = 'gen_sparse';
net_param.p          = 100;
net_param.sparseness = 0.05;  % 0.20 0.15 0.10 0.05
net_param.seed       = 123;
net_param.software   = myif(exist('OCTAVE_VERSION','builtin'), 'octave', 'matlab');
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

% common parameters for neuron network
pm = [];
pm.neuron_model = 'LIF_icc';
pm.nI   = 20;
pm.scee = 0.004;
pm.scie = 0.004;
pm.scei = 0.007;
pm.scii = 0.007;
pm.pr   = 1.0;
pm.ps   = 0.007;
pm.t    = T;
pm.stv  = 0.5;

if exist('id','var') && id == 3

% sub-case 1, 5% connectivity, EI
net_param.sparseness = 0.05;
pm.net_param = net_param;
pm.net = gen_network(net_param);
gen_HH(pm, 'new,ext_T');

% sub-case 2, 10% connectivity, EI
net_param.sparseness = 0.10;
pm.net_param = net_param;
pm.net = gen_network(net_param);
gen_HH(pm, 'new,ext_T');

% sub-case 3, 15% connectivity, EI
net_param.sparseness = 0.15;
pm.net_param = net_param;
pm.net = gen_network(net_param);
gen_HH(pm, 'new,ext_T');

% sub-case 4, 20% connectivity, EI
net_param.sparseness = 0.20;
pm.net_param = net_param;
pm.net = gen_network(net_param);
gen_HH(pm, 'new,ext_T');

end
if exist('id','var') && id == 4

pm.pr   = 2.0;

% sub-case 5, 5% connectivity, EI
net_param.sparseness = 0.05;
pm.net_param = net_param;
pm.net = gen_network(net_param);
gen_HH(pm, 'new,ext_T');

% sub-case 6, 10% connectivity, EI
net_param.sparseness = 0.10;
pm.net_param = net_param;
pm.net = gen_network(net_param);
gen_HH(pm, 'new,ext_T');

% sub-case 7, 15% connectivity, EI
net_param.sparseness = 0.15;
pm.net_param = net_param;
pm.net = gen_network(net_param);
gen_HH(pm, 'new,ext_T');

% sub-case 8, 20% connectivity, EI
net_param.sparseness = 0.20;
pm.net_param = net_param;
pm.net = gen_network(net_param);
gen_HH(pm, 'new,ext_T');

end
