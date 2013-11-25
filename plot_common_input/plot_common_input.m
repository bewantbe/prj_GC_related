%

inpdir  = 'pic_data/';
pic_prefix0 = 'pic_tmp/';

s_pfile = {
'IF_net_2_2_sc=0.010_pr=0.25_ps=0.020_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_net_2_2_sc=0.010_pr=0.50_ps=0.010_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_net_2_2_sc=0.010_pr=0.50_ps=0.020_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_net_2_2_sc=0.010_pr=1.00_ps=0.005_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_net_2_2_sc=0.010_pr=1.00_ps=0.010_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_net_2_2_sc=0.010_pr=2.00_ps=0.005_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_net_2_2_sc=0.010_pr=2.00_ps=0.020_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_net_2_2_sc=0.010_pr=4.00_ps=0.010_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_net_2_2_sc=0.010_pr=8.00_ps=0.005_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_ST_net_2_2_sc=0.010_pr=0.25_ps=0.020_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_ST_net_2_2_sc=0.010_pr=0.50_ps=0.010_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_ST_net_2_2_sc=0.010_pr=0.50_ps=0.020_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_ST_net_2_2_sc=0.010_pr=1.00_ps=0.005_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_ST_net_2_2_sc=0.010_pr=1.00_ps=0.010_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_ST_net_2_2_sc=0.010_pr=2.00_ps=0.005_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_ST_net_2_2_sc=0.010_pr=2.00_ps=0.020_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_ST_net_2_2_sc=0.010_pr=4.00_ps=0.010_data_fullcommon_stv=0.50_t=1.00e+07.mat',
'IF_ST_net_2_2_sc=0.010_pr=8.00_ps=0.005_data_fullcommon_stv=0.50_t=1.00e+07.mat'};

for id_pfile = 1:length(s_pfile)
    fn_save = s_pfile{id_pfile};
    load([inpdir,fn_save]);

    % graph output name
    if mode_IF
        pic_prefix = [pic_prefix0, 'IF'];
    else
        pic_prefix = [pic_prefix0, 'expIF'];
    end
    if mode_ST
        pic_prefix = [pic_prefix, '_ST'];
    end
    pic_prefix = sprintf('%s_%s_sc=%.3f_pr=%.2f_ps=%.3f_', pic_prefix, netstr, scee, pr, ps);
    pic_suffix = sprintf('_fullcommon_stv=%.2f_t=%.2e', stv, simu_time);

    figure(1);
    plot(100.0*s_common_poisson, plain_GC(1,:)./plain_GC(2,:), '-+');
    xlabel('% of common poisson input');
    print('-depsc2',[pic_prefix, 'GCratio_%common', pic_suffix, '.eps']);

%    figure(2);
%    plot(100.0*s_common_poisson, plain_GC, '-+');
%    xlabel('% of common poisson input');
%    print('-depsc2',[pic_prefix, 'flatGC_%common', pic_suffix, '.eps']);

end
