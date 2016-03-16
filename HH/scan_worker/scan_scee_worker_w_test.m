%
neuron_model = 'HH3_gcc49_westmere2';
pr = 0.94;
ps = 0.032;
s_scee = 0.05*linspace(0, 1, 30);
simu_time = 1e6;  % expect: 1.7 hour, actual: 0.768 hour
st_extra = '_test';

scan_scee_worker_head;
