% analysis the data generate by scan_stv_*.m

%function scan_all_analysis
tic();
s_signature = {'data_scan_stv/IF_net_100_rs01_w1'};

pic_prefix0 = 'pic_tmp/';
od_mode = 1; % 1 is 'BIC', 2 is 'AIC', 3 is 'BICall'

if ~exist('font_size','var')
  font_size = 20;
end
if ~exist('line_width','var')
  line_width = 2;
end

switch od_mode
  case 1
    f_od_mode = @(vBIC,vAIC,vBICall) vBIC;
  case 2
    f_od_mode = @(vBIC,vAIC,vBICall) vAIC;
  case 3
    f_od_mode = @(vBIC,vAIC,vBICall) vBICall;
  otherwise
    error('invalid od mode');
end

for id_signature = 1:length(s_signature);
signature = s_signature{id_signature};     % to distinguish different parallel program instances (also dir)
% load these variables: 's_net', 's_time', 's_scee', 's_prps', 's_ps', 's_stv', 's_od', 'hist_div', 'maxod'
load([signature, '_info.mat']);
% get the true "save time interval"
if isempty(strfind(signature,'expIF'))
  time_step = 1.0/32;
else
  time_step = 0.004;
end
s_stv = ceil(s_stv/time_step)*time_step;

% show range
s_id_net  = 1:length(s_net);
s_id_time = 1:length(s_time);
s_id_scee = 1:length(s_scee);
s_id_prps = 1:length(s_prps);
s_id_ps   = 1:length(s_ps);
s_id_stv  = 1:length(s_stv);

for id_net = 1:length(s_net)
 netstr = s_net{id_net};
 neu_network = getnetwork(netstr);
 p = size(neu_network,1);
for id_time = s_id_time
 simu_time = s_time(id_time);
for id_scee = s_id_scee
 scee = s_scee(id_scee);
 id_id_prps = 0;
for id_prps = s_id_prps
 prps = s_prps(id_prps);
 id_id_prps = id_id_prps + 1;
 id_id_ps = 0;
for id_ps = s_id_ps
 ps = s_ps(id_ps);
 id_id_ps = id_id_ps + 1;
 pr = prps / ps;

% prps_ps_stv_oGC = zeros(p, p, length(s_od), length(s_prps), length(s_ps), length(s_stv));
% prps_ps_stv_oDe = zeros(p, p, length(s_od), length(s_prps), length(s_ps), length(s_stv));
% prps_ps_stv_R   = zeros(p, p*(maxod+1), length(s_prps), length(s_ps), length(s_stv));
% prps_ps_aveISI  = zeros(p, length(s_prps), length(s_ps));
% prps_ps_ISI_dis = zeros(p, length(hist_div), length(s_prps), length(s_ps));

% load these variables: 'prps_ps_stv_oGC', 'prps_ps_stvsignature_oDe', 'prps_ps_stv_R', 'prps_ps_aveISI', 'prps_ps_ISI_dis'
 datamatname = sprintf('%s_%s_sc=%g_t=%.3e.mat', signature, netstr, scee, simu_time);
 load(datamatname);

    fprintf('net:%s, sc:%.3f, ps:%.4f, time:%.2e, stv:%.2f, len:%.2e\n',...
     netstr, scee, s_ps(s_id_ps(1)), simu_time, s_stv(1), round(simu_time/s_stv(1)));

    p_select = length(s_neu_id);
    s_aic_od = zeros(size(s_id_stv));
    s_bic_od = zeros(size(s_id_stv));
    s_all_od = zeros(size(s_id_stv));
    s_GC       = zeros(p_select,p_select,length(s_id_stv));
    s_upper_GC = zeros(p_select,p_select,length(s_id_stv));
    s_lower_GC = zeros(p_select,p_select,length(s_id_stv));

    ISI_a_b = prps_ps_aveISI(:, id_prps, id_ps);
    ISI_dis = prps_ps_ISI_dis(:,:,id_prps, id_ps);

    for id_stv = s_id_stv
     stv = s_stv(id_stv);
     len = round(simu_time/stv);                  % !! I don't know the exact expression

        R   = prps_ps_stv_R  (:,:,   id_prps, id_ps, id_stv);
        oGC = prps_ps_stv_oGC(:,:,:, id_prps, id_ps, id_stv);
        oDe = prps_ps_stv_oDe(:,:,:, id_prps, id_ps, id_stv);
        [aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
        [od_joint, od_vec] = chooseROrderFull(R, len, 'BIC');
        bic_od_all = max([od_joint, od_vec]);
        s_aic_od(id_stv) = aic_od;
        s_bic_od(id_stv) = bic_od;
        s_all_od(id_stv) = bic_od_all;
        od = f_od_mode(bic_od, aic_od, bic_od_all);  % bic_od;
        GC = oGC(:,:,od);                            % or zero_GC;  oGC(:,:,20);  oGC(:,:,bic_od);
        [lGC, uGC] = gc_prob_intv(GC, od, len);
        s_GC      (:,:,id_stv) = GC;
        s_lower_GC(:,:,id_stv) = lGC;
        s_upper_GC(:,:,id_stv) = uGC;
    %    [al, de] = ARregression(R(1,1:2:end));
    %    s_var_rate(id_id_ps, id_id_prps) = R(1,1) / de;
    end  % stv

    %%%%%%%%%%%%%%%%%%%
    % output pictures
    if isempty(strfind(lower(signature),lower('expIF')))
        pic_prefix = [pic_prefix0, 'IF'];
    else
        pic_prefix = [pic_prefix0, 'expIF'];
    end
    if ~isempty(strfind(lower(signature),lower('SpikeTrain')))
        pic_prefix = [pic_prefix, '_ST'];
    end
    pic_prefix = sprintf('%s_%s_sc=%.4f_pr=%.4f_ps=%.4f_', pic_prefix, netstr, scee, pr, ps);
    pic_suffix = sprintf('_t=%.2e', simu_time);
    %pic_output = @(st)print('-dpng',[pic_prefix, st, pic_suffix, '.png'],'-r100');    % output function
    %pic_output_color = pic_output;                                        % for color output
    pic_output       = @(st)print('-deps'  ,[pic_prefix, st, pic_suffix, '.eps']);
    pic_output_color = @(st)print('-depsc2',[pic_prefix, st, pic_suffix, '.eps']);

    %% fitting order v.s. stv
    figure(6);  set(gca, 'fontsize',font_size);
    hd=plot(s_stv, s_bic_od, '-o',...
            s_stv, s_all_od, '-x',...
            s_stv, s_aic_od, '-+');
    set(hd, 'linewidth',line_width);
    sa=axis();  sa(3)=0;  axis(sa);
    hd=legend('BIC', 'max BIC', 'AIC');  set(hd, 'fontsize',font_size-2);
    xlabel('\Delta{}t/ms');
    ylabel('fitting order');
    pic_output_color('BIC_AIC_maxBIC');

    %% fitting order v.s. stv
    figure(8);  set(gca, 'fontsize',font_size);
    hd=plot(s_stv, s_stv.*s_bic_od, '-o',...
            s_stv, s_stv.*s_all_od, '-x',...
            s_stv, s_stv.*s_aic_od, '-+');
    set(hd, 'linewidth',line_width);
    sa=axis();  sa(3)=0;  axis(sa);
    hd=legend('BIC time', 'max BIC time', 'AIC time', 'location','northwest');  
    set(hd, 'fontsize',font_size-2);
    xlabel('\Delta{}t/ms');
    ylabel('fitting order * \Delta{}t');
    pic_output_color('BIC_AIC_maxBIC_time');

    %% GC v.s. stv
    % draw on single graph
    figure(7);  clf;  set(gca, 'fontsize',font_size);
    hold on
    s_GC = permute(s_GC, [3,4,1,2]);
    s_lower_GC = permute(s_lower_GC, [3,4,1,2]);
    s_upper_GC = permute(s_upper_GC, [3,4,1,2]);
    st_legend = cell(1,p_select*p_select-p_select);
    s_axis_color = {'green','blue'};
    id_gc = 0;
    for ii=1:p_select
    for jj=1:p_select
        if ii==jj
            continue;
        end
        id_gc = id_gc + 1;
        st_legend{id_gc} = ['GC "',num2str(neu_network(ii,jj)),'" (',num2str(jj),'->',num2str(ii),')'];
        s_gc  = 1000*      s_GC(:,:,ii,jj);
        s_lgc = 1000*s_lower_GC(:,:,ii,jj);
        s_ugc = 1000*s_upper_GC(:,:,ii,jj);
        hd=errorbar(s_stv, s_gc, s_gc-s_lgc, s_ugc-s_gc);
        set(hd, 'linewidth', line_width);
        set(hd, 'color', s_axis_color{id_gc});
        xlabel('\Delta{}t/ms');
        ylabel('GC/0.001');
    end
    end
    hd=legend(st_legend);  set(hd, 'fontsize',font_size-2);
    hold off
    pic_output_color('GC_errbar');

%% draw on different graph
%    fig_cnt = 6;
%    s_GC = permute(s_GC, [3,4,1,2]);
%    s_lower_GC = permute(s_lower_GC, [3,4,1,2]);
%    s_upper_GC = permute(s_upper_GC, [3,4,1,2]);
%    for ii=1:p_select
%    for jj=1:p_select
%        if ii==jj
%            continue;
%        end
%        s_gc  = 1000*      s_GC(:,:,ii,jj);
%        s_lgc = 1000*s_lower_GC(:,:,ii,jj);
%        s_ugc = 1000*s_upper_GC(:,:,ii,jj);
%        fig_cnt = fig_cnt + 1;
%        figure(fig_cnt);  set(gca, 'fontsize',font_size);
%        hd=errorbar(s_stv, s_gc, s_gc-s_lgc, s_ugc-s_gc);  set(hd, 'linewidth', line_width);
%        title(['GC "',num2str(neu_network(ii,jj)),'" (',num2str(jj),'->',num2str(ii),')']);
%        xlabel('\mu*F/0.001');
%        ylabel('GC/0.001');
%        pic_output(sprintf('GC_%d_to_%d', jj, ii));
%    end
%    end

end  % ps
end  % prps
end  % scee
end  % simu_time
end  % net

end % id_signature

toc();

%exit
