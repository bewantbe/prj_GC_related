load('pic_tmp/HH3_gcc49_sparse_ST_net_1000_0X51879353_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40_gc_sort.mat');

% p, use_od, len, plain_gc, plain_network

p = varargin{1};
use_od = varargin{2};
len = varargin{3};
plain_gc = varargin{4};
plain_network = varargin{5};
gc_zero_line = varargin{6};
min_err_gc = varargin{7};
scale_gc = varargin{8};

font_size = 18;
line_width = 1;

pic_prefix = './';
pic_output_color = @(st)print('-depsc2',[pic_prefix, st, '.eps']);

a = 1:(p*p-p);
b = rand(size(plain_gc));
plot(a, b, 'k.');
%rg = 1:999000/4;
%plot(a(rg), b(rg), 'k.');

pic_output_color('_gc_sort');



%matlab -nodisplay
%plot(rand(1,999000), '.');  print('-dpng', 'a.png');

