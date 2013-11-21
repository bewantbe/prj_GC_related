% analysis the data generate by scan_ps_*.m

%function scan_all_analysis
tic();

%s_signature = {'data_scan_ps/w_01_st'};  % ps=0.005, 0.01, 0.02, 0.03, net_2_2 t=1e7 cost 31781.3 sec

s_signature = {'data_scan_ps/w_20'};
%s_signature = {'data_scan_ps/w_21'};

pic_prefix0 = 'pic_tmp/';
od_mode = 1; % 1 is 'BIC', 2 is 'AIC', 3 is 'BICall'

if ~exist('font_size','var')
  font_size = 24;
end
if ~exist('line_width','var')
  line_width = 3;
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
s_id_stv  = 1:length(s_stv);
s_id_prps = 1:length(s_prps);
s_id_ps   = 1:length(s_ps);
%s_id_ps = 1;

for id_net = 1:length(s_net)
 netstr = s_net{id_net};
 matname = ['network/', netstr, '.txt'];
 neu_network = load('-ascii', matname);
 p = size(neu_network, 1);
for id_time = s_id_time
 simu_time = s_time(id_time);
for id_scee = s_id_scee
 scee = s_scee(id_scee);

% prps_ps_stv_oGC = zeros(p, p, length(s_od), length(s_prps), length(s_ps), length(s_stv));
% prps_ps_stv_oDe = zeros(p, p, length(s_od), length(s_prps), length(s_ps), length(s_stv));
% prps_ps_stv_R   = zeros(p, p*(maxod+1), length(s_prps), length(s_ps), length(s_stv));
% prps_ps_aveISI  = zeros(p, length(s_prps), length(s_ps));
% prps_ps_ISI_dis = zeros(p, length(hist_div), length(s_prps), length(s_ps));

% load these variables: 'prps_ps_stv_oGC', 'prps_ps_stvsignature_oDe', 'prps_ps_stv_R', 'prps_ps_aveISI', 'prps_ps_ISI_dis'
 datamatname = sprintf('%s_%s_sc=%g_t=%.3e.mat', signature, netstr, scee, simu_time);
 load(datamatname);
for id_stv = s_id_stv
 stv = s_stv(id_stv);
 len = round(simu_time/stv);                  % !! I don't know the exact expression

    fprintf('net:%s, sc:%.3f, ps:%.4f, time:%.2e, stv:%.2f, len:%.2e\n',...
     netstr, scee, s_ps(s_id_ps(1)), simu_time, s_stv(1), len);

    s_aic_od = zeros(length(s_id_ps), length(s_id_prps));
    s_bic_od = zeros(length(s_id_ps), length(s_id_prps));
    s_all_od = zeros(length(s_id_ps), length(s_id_prps));
    s_GC       = zeros(p,p,length(s_id_ps), length(s_id_prps));
    s_upper_GC = zeros(p,p,length(s_id_ps), length(s_id_prps));
    s_lower_GC = zeros(p,p,length(s_id_ps), length(s_id_prps));
    ISI_a_b  = zeros(p,length(s_id_ps), length(s_id_prps));

     id_id_ps = 0;
    for id_ps = s_id_ps
     ps = s_ps(id_ps);
     id_id_ps = id_id_ps + 1;
     id_id_prps = 0;
    for id_prps = s_id_prps
     prps = s_prps(id_prps);
     id_id_prps = id_id_prps + 1;
     pr = prps / ps;
        aveISI = prps_ps_aveISI(:, id_prps, id_ps);
        ISI_dis = prps_ps_ISI_dis(:,:,id_prps, id_ps);
        oGC = prps_ps_stv_oGC(:,:,:, id_prps, id_ps, id_stv);
        oDe = prps_ps_stv_oDe(:,:,:, id_prps, id_ps, id_stv);
        [aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
        R = prps_ps_stv_R(:,:, id_prps, id_ps, id_stv);
        [od_joint, od_vec] = chooseROrderFull(R, len, 'BIC');
        bic_od_all = max([od_joint, od_vec]);
        s_aic_od(id_id_ps, id_id_prps) = aic_od;
        s_bic_od(id_id_ps, id_id_prps) = bic_od;
        s_all_od(id_id_ps, id_id_prps) = bic_od_all;
        od = f_od_mode(bic_od, aic_od, bic_od_all);  % bic_od;
        GC = oGC(:,:,od);                            % or zero_GC;  oGC(:,:,20);  oGC(:,:,bic_od);
        [lGC, uGC] = gc_prob_intv(GC, od, len);
        s_GC      (:,:,id_id_ps, id_id_prps) = GC;
        s_lower_GC(:,:,id_id_ps, id_id_prps) = lGC;
        s_upper_GC(:,:,id_id_ps, id_id_prps) = uGC;
        ISI_a_b(:, id_id_ps, id_id_prps) = aveISI;
    %    [al, de] = ARregression(R(1,1:2:end));
    %    s_var_rate(id_id_ps, id_id_prps) = R(1,1) / de;
    end  % prps

    %%%%%%%%%%%%%%%%%%%
    % output pictures

    %picname_suf = sprintf('%s_sc=%.3f_ps=%.3g_stv=%.2f_t=%.2e.png',
    % netstr, scee, ps, stv, simu_time);

    mode_eif= ~isempty(strfind(lower(signature),lower('expIF')));
    if mode_eif
        pic_prefix = [pic_prefix0, 'expIF'];
    else
        pic_prefix = [pic_prefix0, 'IF'];
    end
    mode_st = ~isempty(strfind(lower(signature),lower('ST')));
    if mode_st
        pic_prefix = [pic_prefix, '_ST'];
    end
%    pic_prefix = [pic_prefix, '_ST'];
    pic_prefix = sprintf('%s_%s_sc=%.4f_ps=%.4f_', pic_prefix, netstr, scee, ps);
    pic_suffix = sprintf('_stv=%.2f_t=%.2e', stv, simu_time);
    %pic_output = @(st)print('-dpng',[pic_prefix, st, pic_suffix, '.png'],'-r100');    % output function
    %pic_output_color = pic_output;                                        % for color output
    pic_output       = @(st)print('-deps'  ,[pic_prefix, st, pic_suffix, '.eps']);
    pic_output_color = @(st)print('-depsc2',[pic_prefix, st, pic_suffix, '.eps']);
%    pic_output       = @(st)print('-deps'  ,[pic_prefix, st, pic_suffix, '.eps'], ['-F:',num2str(font_size)]);
%    pic_output_color = @(st)print('-depsc2',[pic_prefix, st, pic_suffix, '.eps'], ['-F:',num2str(font_size)]);

    fxs = @log;
    inv_fxs = @exp;
    %fxs = inv_tanpatan(s_prps(s_id_prps(1))/0.001, s_prps(s_id_prps(end))/0.001);
    %inv_fxs = tanpatan(s_prps(s_id_prps(1))/0.001, s_prps(s_id_prps(end))/0.001);
    label_num = 8;
    [xl, x_tick, x_tick_val] = xscale_plot(...
        s_prps(s_id_prps)/0.001, [], fxs, inv_fxs, label_num);

    % Generate Labels in Legend
    label_st_ISI = {};
    label_st_freq = {};
    for kk=1:p
        label_st_ISI  = {label_st_ISI{:}, ['ISI ',num2str(kk)]};
        label_st_freq = {label_st_freq{:}, ['Freq ',num2str(kk)]};
    end

    figure(5);  set(gca, 'fontsize',font_size);
    plot(xl, [squeeze(ISI_a_b(:,1,:)); 1000./squeeze(ISI_a_b(:,1,:))],'linewidth',line_width);
    hd=legend(label_st_ISI{:},label_st_freq{:});  set(hd, 'fontsize',font_size-2);
    xlabel('\mu*F/0.001');
    %ylabel('ave ISI/ms');
    ylabel('average ISI/ms | Freq/Hz');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    pic_output_color('ISI_Freq');

    figure(6);  set(gca, 'fontsize',font_size);
    plot(xl, [s_bic_od(1,:); s_aic_od(1,:); s_all_od(1,:)],'linewidth',line_width);
    hd=legend('BIC', 'AIC', 'max BIC');  set(hd, 'fontsize',font_size-2);
    xlabel('\mu*F/0.001');
    ylabel('fitting order');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    pic_output_color('BIC_AIC_maxBIC');

    fig_cnt = 6;
    s_GC = permute(s_GC, [3,4,1,2]);
    s_lower_GC = permute(s_lower_GC, [3,4,1,2]);
    s_upper_GC = permute(s_upper_GC, [3,4,1,2]);
    for ii=1:p
    for jj=1:p
        if ii==jj
            continue;
        end
        s_gc  = 1000*      s_GC(id_id_ps,:,ii,jj);
        s_lgc = 1000*s_lower_GC(id_id_ps,:,ii,jj);
        s_ugc = 1000*s_upper_GC(id_id_ps,:,ii,jj);
        fig_cnt = fig_cnt + 1;
        figure(fig_cnt);  set(gca, 'fontsize',font_size);
        hd=errorbar(xl, s_gc, s_gc-s_lgc, s_ugc-s_gc);
        set(hd, 'linewidth', line_width);
        title(['GC "',num2str(neu_network(ii,jj)),'" (',num2str(jj),'->',num2str(ii),')']);
        xlabel('\mu*F/0.001');
        ylabel('GC/0.001');
        set(gca,'xtick', x_tick);
        set(gca,'xticklabel',x_tick_val);
        pic_output(sprintf('GC_%d_to_%d', jj, ii));
    end
    end
    s_GC = ipermute(s_GC, [3,4,1,2]);
    s_lower_GC = ipermute(s_lower_GC, [3,4,1,2]);
    s_upper_GC = ipermute(s_upper_GC, [3,4,1,2]);
    end  % ps

end  % stv
end  % scee
end  % simu_time
end  % net

end % id_signature

toc();

%exit
