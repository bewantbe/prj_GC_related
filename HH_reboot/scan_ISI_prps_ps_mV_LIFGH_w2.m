% compute firing freq
addpath([getenv('HOME') '/code/point-neuron-network-simulator/mfile/']);

neuron_model = 'LIF-GH';
extra_cmd = '';
simu_time = 1e7;

s_ps_mV = [...
0.05, 0.07, 0.1, 0.14, 0.2, 0.3, 0.5, 0.7, 1.0, 1.4, 2.0...
];

s_prps_mV = linspace(0.16, 4.5, 200);

prefix_tmpdata = 'ISI_results/';
name_suffix = '';

for ps_mV = s_ps_mV
  scan_ISI_prps_ps_mV_head;
end

% time cost:
% 01:36:15 (Dalma 1n-28c)
