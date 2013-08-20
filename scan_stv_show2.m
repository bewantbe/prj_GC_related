% analysis the data generate by scan_stv_*.m

%function scan_all_analysis
tic();
s_signature = {'data_scan_stv/IF_net_100_rs01_w1'};

ext_suffix = '_w1';
s_neu_show = [1:2];
p_val = 1e-3;

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
 sub_network = neu_network(s_neu_show,s_neu_show);
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
    p_show = length(s_neu_show)
    s_aic_od = zeros(size(s_id_stv));
    s_bic_od = zeros(size(s_id_stv));
    s_all_od = zeros(size(s_id_stv));
    s_GC       = zeros(p_show,p_show,length(s_id_stv));
    s_upper_GC = zeros(p_show,p_show,length(s_id_stv));
    s_lower_GC = zeros(p_show,p_show,length(s_id_stv));
    s_GC_cut    = zeros(1,length(s_id_stv));
    s_overguess = zeros(1,length(s_id_stv));
    s_lackguess = zeros(1,length(s_id_stv));
    s_pairGC    = zeros(p_show,p_show,length(s_id_stv));

    ISI_a_b = prps_ps_aveISI(s_neu_show, id_prps, id_ps);
    ISI_dis = prps_ps_ISI_dis(s_neu_show,:,id_prps, id_ps);

    for id_stv = s_id_stv
      stv = s_stv(id_stv);
      len = round(simu_time/stv);  % !! I don't know the exact expression

      idshowR = false(p_select, maxod+1);
      idshowR(s_neu_show,:) = true;
      %idshowR = reshape(idshowR,1,[]);
      idshowR = find(idshowR);
      R   = prps_ps_stv_R  (s_neu_show,idshowR,   id_prps, id_ps, id_stv);
      oGC = prps_ps_stv_oGC(s_neu_show,s_neu_show,:,id_prps, id_ps, id_stv);
      oDe = prps_ps_stv_oDe(s_neu_show,s_neu_show,:,id_prps, id_ps, id_stv);
      [aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
      [od_joint, od_vec] = chooseROrderFull(R, len, 'BIC');
      bic_od_all = max([od_joint, od_vec]);
      s_aic_od(id_stv) = aic_od;
      s_bic_od(id_stv) = bic_od;
      s_all_od(id_stv) = bic_od_all;
      od = f_od_mode(bic_od, aic_od, bic_od_all);
      GC = oGC(:,:,od);                           % or zero_GC
      [lGC, uGC] = gc_prob_intv(GC, od, len);
      s_GC      (:,:,id_stv) = GC;
      s_lower_GC(:,:,id_stv) = lGC;
      s_upper_GC(:,:,id_stv) = uGC;
 %    [al, de] = ARregression(R(1,1:2:end));
 %    s_var_rate(id_id_ps, id_id_prps) = R(1,1) / de;

      % count the correct edges
      gc_cut_line = chi2inv(1-p_val, od)/len;
      s_GC_cut(id_stv) = gc_cut_line;
      guess_network = GC >= gc_cut_line;
      diff_guess_network = guess_network - sub_network;
      s_overguess(id_stv) = sum(diff_guess_network(:)>0);
      s_lackguess(id_stv) = sum(diff_guess_network(:)<0);

      % use pairwise GC
      s_pairGC(:,:,id_stv) = pairRGrangerT(R(:,1:(od+1)*p_show));
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
    pic_suffix = sprintf('_t=%.2e%s', simu_time, ext_suffix);
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
    figure(7);  set(gca, 'fontsize',font_size);
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
    figure(8);  cla();  set(gca, 'fontsize',font_size);
    hold on
    s_GC = permute(s_GC, [3,1,2]);
    s_lower_GC = permute(s_lower_GC, [3,1,2]);
    s_upper_GC = permute(s_upper_GC, [3,1,2]);
    st_legend = cell(1,p_show*p_show-p_show);
    s_axis_color = {'green','blue'};
    id_gc = 0;
    for ii=1:p_show
      for jj=1:p_show
        disp([num2str(s_neu_show(ii)), ' -> ', num2str(s_neu_show(jj))]);  fflush(stdout);
        if ii==jj
            continue;
        end
        id_gc = id_gc + 1;
        st_legend{id_gc} = ['GC "',...
          num2str(neu_network(s_neu_show(ii),s_neu_show(jj))),...
          '" (',num2str(s_neu_show(jj)),'->',num2str(s_neu_show(ii)),')'];
        s_gc  = 1000*      s_GC(:,ii,jj);
        s_lgc = 1000*s_lower_GC(:,ii,jj);
        s_ugc = 1000*s_upper_GC(:,ii,jj);
        hd=plot(s_stv, s_gc);
        %hd=errorbar(s_stv, s_gc, s_gc-s_lgc, s_ugc-s_gc);
        %set(hd, 'linewidth', line_width);
        %set(hd, 'color', s_axis_color{id_gc});
        if (neu_network(s_neu_show(ii),s_neu_show(jj))~=0)
          set(hd, 'color', 'red');
        end
      end
    end
    plot(s_stv, 1000*s_GC_cut, 'g');
    xlabel('\Delta{}t/ms');
    ylabel('GC/0.001');
    %hd=legend(st_legend);  set(hd, 'fontsize',font_size-2);
    hold off
    pic_output_color('GC_errbar');

    figure(9);  cla();  set(gca, 'fontsize',font_size);
    hold on
    for ii=1:p_show
      for jj=1:p_show
        disp([num2str(s_neu_show(ii)), ' -> ', num2str(s_neu_show(jj))]);  fflush(stdout);
        if ii==jj
            continue;
        end
        s_gc = 1000*squeeze(s_pairGC(ii,jj,:));
        hd=plot(s_stv, s_gc);
        if (neu_network(s_neu_show(ii),s_neu_show(jj))~=0)
          set(hd, 'color', 'red');
        end
     end
    end
    plot(s_stv, 1000*s_GC_cut, 'g');
    xlabel('\Delta{}t/ms');
    ylabel('GC/0.001');
    hold off
    pic_output_color('GC_pairwise');
 
    figure(10);  set(gca, 'fontsize',font_size);
    hd=plot(s_stv, s_overguess, s_stv, s_lackguess);
    set(hd, 'linewidth',line_width);
    hd=legend('over guess', 'lack guess');
    set(hd, 'fontsize',font_size-2);
    pic_output_color('GC_overlackguess');

    figure(12);

end  % ps
end  % prps
end  % scee
end  % simu_time
end  % net

end % id_signature

toc();

%exit
