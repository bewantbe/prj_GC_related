%
neuron_model = 'HH3_gcc49_westmere';
pr = 56.5;
ps = 0.002;
s_scee = 0.05*linspace(0, 1, 30);
simu_time = 5e7;  % expect: 3.7 hour, actual: 2.83 hour

scan_scee_worker_head;
