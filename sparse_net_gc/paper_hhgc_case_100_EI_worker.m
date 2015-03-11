% <TODO: 100neuron, GC: volt, Spike Train * S^EE, S^IE, S^IE, S^II, 这个曲线重要: 有相对量比较>

rand('state', 2143);
netadj_100_s20_unif = 1*(rand(100, 100) < 0.2);
netadj_100_s20_unif(eye(100)==1) = 0;
netadj_100_s20_unif = netadj_100_s20_unif .* rand(100, 100);

%figure(1);
%imagesc(netadj_100_s20_unif);
%caxis([0,1]);
%colorbar();

%return

pm = [];
%pm.neuron_model = 'HH3_gcc49';
pm.neuron_model = 'HH3_gcc49_native';
pm.net  = netadj_100_s20_unif;
pm.nE   = 80;
pm.nI   = 20;
pm.scee = 0.05;
pm.scie = 0.05;
pm.scei = 0.09;
pm.scii = 0.09;
pm.pr   = 2.0;
pm.ps   = 0.03;
pm.t    = 1e6;
pm.stv  = 0.5;

max_od = 40;
i_stv   = 1;  % Down sampling factor

%[X, ISI, ras, pm] = gen_HH(pm, 'ext_T, new, rm');
%hist(ISI);
%return;

gen_HH(pm, 'ext_T');  % about 

suffix_extra = '_unif_s';

b_use_spike_train = false;
GCHH_analyse_core;
b_use_spike_train = true;
GCHH_analyse_core;

