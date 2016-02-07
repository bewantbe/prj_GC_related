%
addpath('/home/xyy/code/point-neuron-network-simulator/mfile');
 
pm = [];
pm.neuron_model = 'HH-GH';  % one of LIF-G, LIF-GH, HH-GH
%pm.neuron_model = 'LIF-GH';  % one of LIF-G, LIF-GH, HH-GH
%pm.neuron_model = 'LIF-G';  % one of LIF-G, LIF-GH, HH-GH
pm.net  = 0;
pm.nI   = 0;
pm.scee = 1e-7;
pm.pr   = 1.6;
%pm.pr   = 0;
pm.ps   = 1e-7;
pm.t    = 1e3;
pm.dt   = 0.01;
pm.stv  = 0.01;
%pm.stv  = 0.5;
pm.seed = 'auto';
pm.extra_cmd = '--input-event-path ep.txt';

fd = fopen('ep.txt','w');
fprintf(fd, '0 500.0\n');
fclose(fd);

X = gen_neu(pm, 'new,rm');
s_t = pm.stv * (1:size(X,2));

rg_bg = ceil(500/pm.stv);
rg_len = round(100/pm.stv);
rg = rg_bg:rg_bg+rg_len;

figure(1);
plot(s_t(rg)-s_t(rg(1)), X(1,rg)-X(1,rg(1)));

ratio = (max(X(1,rg))-X(1,rg(1))) / pm.ps

