% in big network, show GC v.s. fitting order

%gcdata_path = 'result_HH_net_100_01_p[80,20]_sc=[0.050,0.050,0.100,0.100]_pr=1.60_ps=0.040_stv=0.50_t=1.00e+06_l_w.mat';
gcdata_path = 'result_HH_net_100_01_p[80,20]_sc=[0.050,0.050,0.100,0.100]_pr=1.60_ps=0.040_stv=0.50_t=1.00e+06_w.mat';
gcdata_path = 'result_HH_net_100_01_p[80,20]_sc=[0.050,0.050,0.100,0.100]_pr=1.60_ps=0.040_stv=0.50_t=1.00e+06.mat';
gcdata_path = 'result_HH_net_100_01_p[80,20]_sc=[0.050,0.050,0.100,0.100]_pr=1.60_ps=0.040_stv=0.50_t=1.00e+06_cov_l_w.mat';

is_octave = exist('OCTAVE_VERSION','builtin') ~= 0;
if is_octave
%    font_size = 28;
    font_size = 24;
    line_width = 5;
else
    font_size = 24;
    line_width = 2;
end

pic_prefix0 = 'pic_tmp/';
res_dir = 'result_GC_simple/';

set(0, 'defaultfigurevisible', 'off');

p_val = 1e-5;

load([res_dir, gcdata_path]);
neu_network = getnetwork(pm.net);
p = size(neu_network,1);
max_od = size(oGC, 3);
plain_network = neu_network;
plain_network = plain_network(eye(p)==0);

s_gc = zeros(p*p-p, max_od);
for od = 1:max_od
  plain_gc = oGC(:,:,od);
  plain_gc = plain_gc(eye(p)==0);
  s_gc(:, od) = plain_gc;
end

% setup output path and format
pic_prefix = '';
if ~exist('mode_IF','var') || strcmpi(mode_IF,'IF')
    pic_prefix = [pic_prefix0, 'IF'];
else
    pic_prefix = [pic_prefix0, mode_IF];
end
if exist('mode_ST','var') && mode_ST
    pic_prefix = [pic_prefix, '_ST'];
end
if ~isfield(pm, 'nI') || pm.nI==0
  st_para = sprintf('_%s_sc=%1.3f_pr=%1.2f_ps=%1.3f_stv=%1.2f_t=%1.2e',...
                    pm.net, pm.scee, pm.pr, pm.ps, pm.stv, pm.t);
else
    st_para = sprintf('_%s_p[%d,%d]_sc=[%1.3f,%1.3f,%1.3f,%1.3f]_pr=%1.2f_ps=%1.3f_stv=%1.2f_t=%1.2e',...
                      pm.net, pm.nE, pm.nI, pm.scee, pm.scie, pm.scei, pm.scii, pm.pr, pm.ps, pm.stv, pm.t);
end
[an, bn] = fileparts(gcdata_path);
fn_suffix = bn( find(bn=='+', 1, 'last') + 3 : end);
pic_prefix = [pic_prefix, st_para, fn_suffix];
pic_output       = @(st)print('-deps'  ,[pic_prefix, st, '.eps']);
pic_output_color = @(st)print('-depsc2',[pic_prefix, st, '.eps']);

tic
figure(1);
plot(s_gc');  % 335.6 sec
toc
tic
pic_output_color('_gc_od');  % 28 sec
toc

tic
figure(2);
plot((s_gc - ones(p*p-p,1)*(1:max_od)/len)');
toc
tic
pic_output_color('_gc_od0');
toc

