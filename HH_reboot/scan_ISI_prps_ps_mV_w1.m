% compute firing freq

s_ps_mV = [...
0.05, 0.07, 0.1, 0.14, 0.2, 0.3, 0.5, 0.7, 1.0, 1.4, 2.0...
];

for ps_mV = s_ps_mV
  scan_ISI_prps_ps_mV_head;
end
