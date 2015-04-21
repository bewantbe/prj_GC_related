%
    is_octave = exist('OCTAVE_VERSION','builtin') ~= 0;
    if is_octave
        fontsize = 22;
        linewidth = 3;
    else
        fontsize = 16;
        linewidth = 1;
    end
    pic_prefix = 'pic_tmp/';
    pic_output       = @(st)print('-deps',  [pic_prefix, st, '.eps']);
    pic_output_color = @(st)print('-depsc2',[pic_prefix, st, '.eps']);
%    set(0, 'defaultfigurevisible', 'off');
    set(0, 'defaultlinelinewidth', linewidth);
    set(0, 'defaultaxesfontsize', fontsize);

a=[  % n = 50
100	100	100	100	100	100
100	100	100	100	100	100
100	99.9	100	100	100	100
100	99.3	100	99.8	100	99.8];
a(:,:,2) = [  % n = 100
100	100	100	100	100	100
100	100	100	99.9	100	99.9
100	100	100	98.2	100	98.2
100	100	100	77.6	100	77.6
];
a(:,:,3) = [  % n = 200
100	99.9	94.8	94.8	100	100
100	46.5	89.1	88.7	100	84.8
96.2	15.3	52.0	15.5	99.4	15.3
84.8	20.2	38.5	20.2	85.3	20.2
];
a(:,:,4) = [  % n = 400
99.9	80.1	94.8	94.7	100	97.5
92.6	10.1	62.0	10.1	95.6	10.1
81.0	15.1	56.0	15.1	87.8	15.1
72.7	20.1	52.4	20.1	81.5	20.1
];
a(:,:,5) = [  % n = 1000
100.0	85.4	99.8	99.1	99.8	99.1
98.0	10.0	97.8	10.0	97.8	10.0
93.7	15.0	92.9	15.0	92.9	15.0
88.8	20.0	86.5	20.0	86.5	20.0
];

figure(1);
h1=plot(squeeze(a(1,1,:)), '-.b');
hold on
h2=plot(squeeze(a(2,1,:)), '-+b');
h3=plot(squeeze(a(3,1,:)), '-xb');
h4=plot(squeeze(a(4,1,:)), '-ob');

h1=plot(squeeze(a(1,2,:)), '-.r');
h2=plot(squeeze(a(2,2,:)), '-+r');
h3=plot(squeeze(a(3,2,:)), '-xr');
h4=plot(squeeze(a(4,2,:)), '-or');

hold off
set(gca, 'xtick', [1 2 3 4], 'xticklabel', [50 100 200 400 1000]);
legend({'volt-join  5%','volt-join 10%','volt-join 15%','volt-join 20%',...
        'volt-pair  5%','volt-pair 10%','volt-pair 15%','volt-pair 20%'});
legend('location', 'southwest');
ylim([0,100]);
print('-depsc2', 'pic/sparseness_n_scan_volt_join_pair.eps');

figure(2);
h1=plot(squeeze(a(1,5,:)), '-.b');
hold on
h2=plot(squeeze(a(2,5,:)), '-+b');
h3=plot(squeeze(a(3,5,:)), '-xb');
h4=plot(squeeze(a(4,5,:)), '-ob');

h1=plot(squeeze(a(1,6,:)), '-.r');
h2=plot(squeeze(a(2,6,:)), '-+r');
h3=plot(squeeze(a(3,6,:)), '-xr');
h4=plot(squeeze(a(4,6,:)), '-or');

hold off
set(gca, 'xtick', [1 2 3 4 5], 'xticklabel', [50 100 200 400 1000]);
legend({'ST-join  5%','ST-join 10%','ST-join 15%','ST-join 20%',...
        'ST-pair  5%','ST-pair 10%','ST-pair 15%','ST-pair 20%'});
legend('location', 'southwest');
ylim([0,100]);
print('-depsc2', 'pic/sparseness_n_scan_ST_join_pair.eps');


