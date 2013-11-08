% 
pic_common_include;

addpath('extra_data');

f_len_guess = @(od, F1) (1.153+sqrt(od-0.513)/1.917) * (10.002 ./ F1);
gc_scale = 1e-4;

%s_signature = {'extra_data/data_scan_ps/w_20'};
%s_signature = {'extra_data/data_scan_ps/w_21'};

s_signature = {'extra_data/data_scan_ps/w_01_st'};

pic_prefix0 = 'pic_tmp/';
od_mode = 1; % 1 is 'BIC', 2 is 'AIC', 3 is 'BICall'
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

for id_signature = 1:length(s_signature)
signature = s_signature{id_signature};
load([signature, '_info.mat']);
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
%s_id_ps   = 1:length(s_ps);
s_id_ps   = 2:3;

for id_net = 1:length(s_net)
 netstr = s_net{id_net};
 %matname = ['network/', netstr, '.txt'];
 %neu_network = load('-ascii', matname);
 neu_network = getnetwork(netstr);
 p = size(neu_network, 1);
for id_time = s_id_time
 simu_time = s_time(id_time);
for id_scee = s_id_scee
 scee = s_scee(id_scee);
 datamatname = sprintf('%s_%s_sc=%g_t=%.3e.mat', signature, netstr, scee, simu_time);
 load(datamatname);
for id_stv = s_id_stv
 stv = s_stv(id_stv);
 len = round(simu_time/stv);

    fprintf('net:%s, sc:%.3f, ps:%.4f, time:%.2e, stv:%.2f, len:%.2e\n',...
     netstr, scee, s_ps(s_id_ps(1)), simu_time, s_stv(1), len);

    s_aic_od = zeros(length(s_id_ps), length(s_id_prps));
    s_bic_od = zeros(length(s_id_ps), length(s_id_prps));
    s_all_od = zeros(length(s_id_ps), length(s_id_prps));
    s_GC       = zeros(p,p,length(s_id_ps), length(s_id_prps));
    s_upper_GC = zeros(p,p,length(s_id_ps), length(s_id_prps));
    s_lower_GC = zeros(p,p,length(s_id_ps), length(s_id_prps));
    ISI_a_b  = zeros(p,length(s_id_ps), length(s_id_prps));
    s_zero_GC  = zeros(p,p,length(s_id_ps), length(s_id_prps));
    s_len_min  = zeros(1, length(s_id_prps));

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

        s_zero_GC(:,:, id_id_ps, id_id_prps) = zero_GC;
        s_len_min(id_id_prps) = f_len_guess(od, zero_GC(2,1));
    end  % prps

    %%%%%%%%%%%%%%%%%%%
    % output pictures
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
    pic_prefix = sprintf('%s_%s_sc=%.4f_ps=%.4f_', pic_prefix, netstr, scee, ps);
    pic_suffix = sprintf('_stv=%.2f_t=%.2e', stv, simu_time);
    pic_output       = @(st)print('-deps'  ,[pic_prefix, st, pic_suffix, '.eps']);
    pic_output_color = @(st)print('-depsc2',[pic_prefix, st, pic_suffix, '.eps']);

    fxs = @log;
    inv_fxs = @exp;
    label_num = 4;
    [xl, x_tick, x_tick_val] = xscale_plot(...
        s_prps(s_id_prps)/0.001, [], fxs, inv_fxs, label_num);

    s_GC = permute(s_GC, [3,4,1,2]);
    s_lower_GC = permute(s_lower_GC, [3,4,1,2]);
    s_upper_GC = permute(s_upper_GC, [3,4,1,2]);

    ii=2;
    jj=1;
        s_gc  = 1/gc_scale*      s_GC(id_id_ps,:,ii,jj);
        s_lgc = 1/gc_scale*s_lower_GC(id_id_ps,:,ii,jj);
        s_ugc = 1/gc_scale*s_upper_GC(id_id_ps,:,ii,jj);
        figure(1);
        hd=errorbar(xl, s_gc, s_gc-s_lgc, s_ugc-s_gc);
        %title(['GC "',num2str(neu_network(ii,jj)),'" (',num2str(jj),'->',num2str(ii),')']);
        xlabel(sprintf('\mu*F/%.1e',gc_scale));
        ylabel(sprintf('GC/%.1e',gc_scale));
        set(gca,'xtick', x_tick);
        set(gca,'xticklabel',x_tick_val);
        pic_output(sprintf('GC_%d_to_%d', jj, ii));
    s_GC = ipermute(s_GC, [3,4,1,2]);
    s_lower_GC = ipermute(s_lower_GC, [3,4,1,2]);
    s_upper_GC = ipermute(s_upper_GC, [3,4,1,2]);

    % Generate Labels in Legend
    label_st_ISI = {};
    label_st_freq = {};
    for kk=1:p
        label_st_ISI  = {label_st_ISI{:}, ['ISI ',num2str(kk)]};
        label_st_freq = {label_st_freq{:}, ['Freq ',num2str(kk)]};
    end

    figure(2);
    plot(xl, [s_bic_od(1,:); s_aic_od(1,:); s_all_od(1,:)]);
    hd=legend('BIC', 'AIC', 'max BIC');  set(hd, 'fontsize',fontsize-2);
    xlabel('\mu*F/0.001');
    ylabel('fitting order');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    pic_output_color('BIC_AIC_maxBIC');

    figure(3);
    plot(xl, [squeeze(ISI_a_b(:,1,:)); 1000./squeeze(ISI_a_b(:,1,:))]);
    hd=legend(label_st_ISI{:},label_st_freq{:});  set(hd, 'fontsize',fontsize-2);
    xlabel('\mu*F/0.001');
    ylabel('Ave ISI/ms | Freq/Hz');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    pic_output_color('ISI_Freq');

    figure(4);
    plot(xl, s_len_min*stv/1e3/60);
    xlabel('\mu*F/0.001');
    ylabel('time / min');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    pic_output_color('Tmin');

    end  % ps

end  % stv
end  % scee
end  % simu_time
end  % net

end % id_signature
