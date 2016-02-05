%
neuron_model = 'HH3_gcc49_westmere';
pr = 95;
ps = 0.002;
s_scee = 0.05*linspace(0, 1, 30);
simu_time = 5e7;  % expect 5.23h

scan_scee_worker_head;
