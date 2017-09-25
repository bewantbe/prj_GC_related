% compute firing freq
addpath([getenv('HOME') '/code/point-neuron-network-simulator/mfile/']);

neuron_model = 'HH-GH';
extra_cmd = '--set-threshold 20';
simu_time = 1e5;

s_ps_mV = [...
0.05, 0.07, 0.1, 0.14, 0.2, 0.3, 0.5, 0.7, 1.0, 1.4, 2.0...
];

PSP = get_neu_psp(neuron_model);
s_prps_mV = linspace(0.003,0.5, 100) / PSP.mV_ps;

prefix_tmpdata = 'ISI_test/';
name_suffix = '_VT=20';

for ps_mV = s_ps_mV
  scan_ISI_prps_ps_mV_head;
end

% time cost:
% 193.038  151.018  117.299  96.039 78.558
