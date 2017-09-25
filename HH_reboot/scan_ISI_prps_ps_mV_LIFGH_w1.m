% compute firing freq
addpath([getenv('HOME') '/code/point-neuron-network-simulator/mfile/']);

neuron_model = 'LIF-GH';
extra_cmd = '';
simu_time = 1e5;

%s_ps_mV = [...
%0.05, 0.07, 0.1, 0.14, 0.2, 0.3, 0.5, 0.7, 1.0, 1.4, 2.0...
%];

s_ps_mV = [...
0.05, 0.1, 0.2, 0.5, 1.0, 2.0...
];

s_prps_mV = linspace(0.16, 4.5, 20);

prefix_tmpdata = 'ISI_test/';
name_suffix = '';

for ps_mV = s_ps_mV
  scan_ISI_prps_ps_mV_head;
end

% time cost:
% 7.480  5.970  5.008  4.535  4.305  4.179
