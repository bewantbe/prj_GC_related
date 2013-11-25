% head of scan_correct_

netstr = 'net_2_2';
scee   = 0.01;
pr     = 0.35;
ps     = 0.01;
simu_time = 60e3 * 3.44;
stv = 0.5;
extst = ' --RC-filter -q';
mode_ST = 0;
s_od = 1:50;

% job index set
s_jobs = 1:10000;

b_have_head = true;
scan_correct_rate;
b_have_head = false;
