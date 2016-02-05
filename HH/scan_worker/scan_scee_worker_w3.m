%
neuron_model = 'HH3_gcc49_westmere';
pr = 5.93;
ps = 0.032;
s_scee = 0.05*linspace(0, 1, 30);
simu_time = 5e7;  % expect: 1.9 hour

scan_scee_worker_head;
