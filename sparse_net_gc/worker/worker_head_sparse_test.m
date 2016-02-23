% Scan sparseness of big network.

%input:
%simu_time = 1e5;
%p = 100;
%s_sparseness = linspace(1, round(sqrt(p*4)), 30)/p;
%Note:
% p * prob * prob = const.; prob = o/p;
% o = sqrt(const. * p);

%% Fixed parameters

net_param = [];
net_param.generator  = 'gen_sparse_mt19937';
net_param.p          = p;
%net_param.sparseness = 3/net_param.p;
%net_param.seed       = 4563;
net_param.software   = 'MT19937';

pm = [];
pm.neuron_model = 'HH3_gcc49_westmere2_nogui';
pm.net_param = net_param;
%pm.net  = gen_network(net_param);
pm.nI   = round(0.2*net_param.p);
pm.nE   = net_param.p - pm.nI;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.10;
pm.scii = 0.10;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = simu_time; % 1e5;
pm.stv  = 0.5;
pm.extra_cmd = '-q';

use_od = 40;

if ~exist('identity_str', 'var')
  identity_str = datestr(now, 30);
end

% temp file will be saved here
%prefix_tmpdata = ['data/' mfilename '_' datestr(now, 30) '_'];
prefix_tmpdata = ['data/' identity_str '_'];

% results will be saved here
data_file_name = sprintf('scan_sparseness/scan_%s_sparse=%.1e-%.1e_p=%d_pr=%1.1f_ps=%.1e_scee=%.1e_t=%1.1e_%s.mat', pm.neuron_model, s_sparseness(1), s_sparseness(end), net_param.p, pm.pr, pm.ps, pm.scee, pm.t, identity_str);

rng('shuffle');             % make output of rand random.
rng_state_curr = rng();     % used to reproduce the results.
save('-v7', [data_file_name '.rng'], 'rng_state_curr');  % will be removed once job finished.

in_const_data.rng_state_curr = rng_state_curr;
in_const_data.pm = pm;
in_const_data.net_param = net_param;
in_const_data.use_od = use_od;
in_const_data.identity_str = identity_str;

s_jobs = cell(size(s_sparseness));
for k=1:numel(s_jobs)
  in.sparseness = s_sparseness(k);
  in.net_seed = randi(2^31-1);
  s_jobs{k}=in;   % inputs are saved in a struct named 'in'
end

%prefix_tmpdata = 'data/';
addpath([getenv('HOME') '/matcode/prj_GC_clean/HH/scan_worker']);
t0 = tic();
parallel_distributor;
delete([data_file_name '.rng']);
fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );

