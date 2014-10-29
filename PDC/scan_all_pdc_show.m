% show pdc scan results
set(0, 'defaultfigurevisible', 'off');
line_width = 2;
set(0, 'defaultlinelinewidth', line_width);
font_size = 16;
set(0, 'defaultaxesfontsize', font_size);
tic();

% for final thesis
s_signature = {'data_scan_IF/w2_net_2_2'};

pic_prefix0 = 'pic_tmp/';
gc_od_mode = 'BIC';         % Order used for GC value: 'BIC','AIC','maxBIC','zero' or number

if isnumeric(gc_od_mode)
  if gc_od_mode==-1
    f_gc_od = @(oGC, zero_GC, bic_od, aic_od, bic_odmax) abs(zero_GC);
  elseif gc_od_mode==0
    f_gc_od = @(oGC, zero_GC, bic_od, aic_od, bic_odmax) zero_GC;
  elseif gc_od_mode>0
    f_gc_od = @(oGC, zero_GC, bic_od, aic_od, bic_odmax) oGC(:,:,gc_od_mode);
  else
    error('invalid GC od mode');
  end
else
  switch gc_od_mode
    case 'BIC'
      f_gc_od = @(oGC, zero_GC, bic_od, aic_od, bic_odmax) oGC(:,:,bic_od);
    case 'AIC'
      f_gc_od = @(oGC, zero_GC, bic_od, aic_od, bic_odmax) oGC(:,:,aic_od);
    case 'maxBIC'
      f_gc_od = @(oGC, zero_GC, bic_od, aic_od, bic_odmax) oGC(:,:,bic_odmax);
    case 'zero'
      f_gc_od = @(oGC, zero_GC, bic_od, aic_od, bic_odmax) zero_GC;
    otherwise
      error('invalid GC od mode');
  end
end

for id_signature = 1:length(s_signature)
signature = s_signature{id_signature};     % to distinguish different program instances (also dir)
% load these variables: 's_net', 's_time', 's_scee', 's_prps', 's_ps', 's_stv', 's_od', 'hist_div', 'maxod'
load([signature, '_info.mat']);
% get the true "save time interval"
if isempty(strfind(signature,'expIF'))
  time_step = 1.0/32;
  p_value = 1e-15;
else
  time_step = 0.004;
  p_value = 1e-15;
end
s_stv = ceil(s_stv/time_step)*time_step;

% show range
s_id_net  = 1:length(s_net);
s_id_time = 1:length(s_time);
s_id_scee = 1:length(s_scee);
s_id_stv  = 1:length(s_stv);
s_id_prps = 1:length(s_prps);
s_id_ps   = 1:length(s_ps);

for id_net = s_id_net
 netstr = s_net{id_net};
 neu_network = getnetwork(netstr);
 p = size(neu_network, 1);
for id_time = s_id_time
 simu_time = s_time(id_time);
for id_scee = s_id_scee
 scee = s_scee(id_scee);

% load these variables: 'prps_ps_stv_oGC', 'prps_ps_stvsignature_oDe', 'prps_ps_stv_R', 'prps_ps_aveISI', 'prps_ps_ISI_dis'
 datamatname = sprintf('%s_%s_sc=%g_t=%.3e.mat', signature, netstr, scee, simu_time);
 load(datamatname);
for id_stv = s_id_stv
 stv = s_stv(id_stv);
 len = round(simu_time/stv);                  % !! I don't know the exact expression

    s_zero_GC = zeros(p,p,length(s_id_ps), length(s_id_prps));
    s_aic_od = zeros(length(s_id_ps), length(s_id_prps));
    s_bic_od = zeros(length(s_id_ps), length(s_id_prps));
    s_all_od = zeros(length(s_id_ps), length(s_id_prps));
    ISI_a_b  = zeros(length(s_id_ps), length(s_id_prps));
    wrong_num = zeros(length(s_id_ps), length(s_id_prps));
    s_pdc1_SM = zeros(length(s_id_ps), length(s_id_prps));
    s_pdc0_SM = zeros(length(s_id_ps), length(s_id_prps));
    s_pdc1_max = zeros(length(s_id_ps), length(s_id_prps));
    s_pdc0_max = zeros(length(s_id_ps), length(s_id_prps));

    id_id_prps = 0;
    for id_prps = s_id_prps
     prps = s_prps(id_prps);
     id_id_prps = id_id_prps + 1;
     id_id_ps = 0;
    for id_ps = s_id_ps
     ps = s_ps(id_ps);
     id_id_ps = id_id_ps + 1;
     pr = prps / ps;
        aveISI = prps_ps_aveISI(:, id_prps, id_ps);
        ISI_dis = prps_ps_ISI_dis(:,:,id_prps, id_ps);
        oGC = prps_ps_stv_oGC(:,:,:, id_prps, id_ps, id_stv);
        oDe = prps_ps_stv_oDe(:,:,:, id_prps, id_ps, id_stv);
        [aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
%        R = prps_ps_stv_R(:,:, id_prps, id_ps, id_stv);
%        [od_joint, od_vec] = chooseROrderFull(R, len, 'BIC');
%        bic_od_all = max([od_joint, od_vec]);
        f_eff = @(x) myif(min(aveISI)<1e3, x, Inf);
        bic_od_all = 0;
        s_aic_od(id_id_ps, id_id_prps) = aic_od;
        s_bic_od(id_id_ps, id_id_prps) = bic_od;
        s_zero_GC(:,:,id_id_ps, id_id_prps) = f_gc_od(oGC, zero_GC, bic_od, aic_od, bic_od_all);
        ISI_a_b(id_id_ps, id_id_prps) = mean(aveISI);
        net_diff = (gc_prob_nonzero(oGC(:,:,bic_od), bic_od, len)>1-p_value) - neu_network;
        wrong_num(id_id_ps, id_id_prps) = sum(abs(net_diff(:)));

        pdc = prps_ps_stv_PDC(:,:,:, id_prps, id_ps, id_stv);
        pdc_SM = real(mean( pdc.*conj(pdc), 3 ));
        s_pdc1_SM(id_ps, id_prps) = max(pdc_SM(neu_network~=0));
        s_pdc0_SM(id_ps, id_prps) = max(pdc_SM(neu_network==0&eye(p)==0));
        pdc_plain = reshape(abs(pdc), p*p, []);
        s_pdc1_max(id_ps, id_prps) = max(pdc_plain(neu_network~=0, :)(:));
        s_pdc0_max(id_ps, id_prps) = max(pdc_plain(neu_network==0&eye(p)==0, :)(:));
    end  % ps
    end  % prps

    gc_scale = 0.001;
    [xx,yy] = meshgrid(s_prps(s_id_prps)/0.001, s_ps(s_id_ps)/0.001);

    s_zero_GC = permute(s_zero_GC, [3,4,1,2]);

    k1 = zeros(size(s_zero_GC,1), size(s_zero_GC,2));
    k2 = zeros(size(s_zero_GC,1), size(s_zero_GC,2));
    k3 = zeros(size(s_zero_GC,1), size(s_zero_GC,2));
    for j1=1:size(s_zero_GC,1)
    for j2=1:size(s_zero_GC,2)
      G1 = s_zero_GC(j1,j2,:,:);
      a = G1(neu_network > 0.5 & eye(p) < 0.5);       % the GC of "one"
      b = G1(neu_network < 0.5 & eye(p) < 0.5);       % the GC of "zero"
      if (isempty(a)==1)
        a = ones(p*(p-1),1)*NaN;
      end
      if (isempty(b)==1)
        b = ones(p*(p-1),1)*NaN;
      end
      amax = max(a);
      amin = min(a);
      bmax = max(b);
      bmin = min(b);
      k1(j1,j2) = amin/bmax;
      k2(j1,j2) = amax/amin;
      k3(j1,j2) = bmax/bmin;
    end
    end
    if a(1)~=a(1) || b(1)~=b(1)
      k1=zeros(size(s_zero_GC,1),size(s_zero_GC,2));
      k2=zeros(size(s_zero_GC,1),size(s_zero_GC,2));
      k3=zeros(size(s_zero_GC,1),size(s_zero_GC,2));
    end

    k1(imag(k1)~=0) = NaN;

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
    pic_prefix = sprintf('%s_%s_sc=%.4f_', pic_prefix, netstr, scee);
    pic_suffix = sprintf('_stv=%.2f_t=%.2e', stv, simu_time);
    %pic_output = @(st)print('-dpng',[pic_prefix, st, pic_suffix, '.png'],'-r100');    % output function
    %pic_output_color = pic_output;                                        % for color output
    pic_output       = @(st)print('-deps'  ,[pic_prefix, st, pic_suffix, '.eps']);
    pic_output_color = @(st)print('-depsc2',[pic_prefix, st, pic_suffix, '.eps']);

    pic_data_save = @(st, varargin)save('-v7', [pic_prefix, st, '.mat'], 'varargin');

%    figure(1);
%    pcolor(xx,yy,k1);
%    caxis([0,5]);
%    shading('flat');
%    colorbar
%    xlabel('\mu*F/0.001');
%    ylabel('F / 0.001');
%    pic_output_color('k1_map');

%    figure(2);
%    plot(s_prps/0.001, 1000./ISI_a_b(ceil(end/2),:),'-+','linewidth',line_width);
%    xlabel('\mu*F/0.001');
%    ylabel('firing frequency /Hz');
%    pic_output('aveISI');

    %fxs = @log;
    %inv_fxs = @exp;
    fxs = @(x) log10(x-4)+4;
    inv_fxs = @(x) 10.^(x-4)+4;
    %fxs = inv_tanpatan(s_prps(s_id_prps(1))/0.001, s_prps(s_id_prps(end))/0.001);
    %inv_fxs = tanpatan(s_prps(s_id_prps(1))/0.001, s_prps(s_id_prps(end))/0.001);

    % get labels and ticks for non-linear scaled plot
    label_num = 6;
    [xl, x_tick, x_tick_val] = xscale_plot(...
        s_prps(s_id_prps)/0.001, [], fxs, inv_fxs, label_num);
    f_str_cell = @(xtv) cellfun(@(n)sprintf('%.2g', n), num2cell(xtv), 'UniformOutput', false);
    x_tick_val = f_str_cell(x_tick_val);  % workaround for Octave bug
    [xx2,yy2] = meshgrid(xl, s_ps(s_id_ps)/0.001);

    % plot ISI
    figure(3);
    hd = plot(xl, ISI_a_b([1,ceil(size(ISI_a_b,1)/2),end],:),':', xl, 1000./ISI_a_b([1,ceil(size(ISI_a_b,1)/2),end],:),'-+');
    set(hd, 'linewidth',line_width);
    hd=legend(['F=',num2str(s_ps(1)),' ISI'],...
              ['F=',num2str(s_ps(ceil(size(s_ps,2)/2))),' ISI'],...
              ['F=',num2str(s_ps(end)),' ISI'],...
              ['F=',num2str(s_ps(1)),' freq'],...
              ['F=',num2str(s_ps(ceil(size(s_ps,2)/2))),' freq'],...
              ['F=',num2str(s_ps(end)),' freq'],...
              'location','northwest');
    %set(hd, 'fontsize',font_size-3);
    if isempty(strfind(signature,'expIF'))
        axis([min(xl) max(xl) 0 200]);
    else
        sa=axis();  sa([3,4])=[0,200];  axis(sa);
    end
    ylabel('ave ISI/ms | Freq/Hz');
    xlabel('\mu*F/0.001');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel', x_tick_val);
    pic_output_color('aveISI_Freq_xlog');

    % plot GC ratio
    figure(5);
    pcolor(xx2,yy2,k1);
    axis([min(xl), max(xl), 0, s_ps(end)/0.001]);
    if mode_st
        caxis([0,100]);
    else
        caxis([0,15]);
    end
    axis([min(xl), max(xl), 0, s_ps(end)/0.001]);
    %shading('flat');
    shading('interp');
    hd = colorbar();
    %set(hd, 'fontsize',font_size);
%    title('minGC1/maxGC0 map');
    ylabel('F / 0.001');
    xlabel('\mu*F/0.001');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    pic_output_color('k1_map_xlog');
    pic_data_save('k1_map_xlog',xx2,yy2,k1);

    % plot BIC map
    figure(6);%  set(gca, 'fontsize',font_size);
    pcolor(xx2,yy2,s_bic_od);
    if mode_st
        caxis([0,100]);
    else
        caxis([0,100]);
    end
    shading('flat');
    %shading('interp');
    colorbar();
    axis([min(xl), max(xl), 0, s_ps(end)/0.001]);
%    title('bic map');
    ylabel('F / 0.001');
    xlabel('\mu*F/0.001');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    pic_output_color('bic_map_xlog');

    % plot GC map of all possible edges
    figure(7);%  set(gca, 'fontsize',font_size);
    if mode_st
        caxis_gc_low = 0.1;
        caxis_gc_high= 5.0;
    else
        caxis_gc_low = 0.5;
        caxis_gc_high= 5.0;
    end
    for ii=1:p
    for jj=1:p
        if ii==jj
        continue;
        end
        figure(7);
        pcolor(xx2, yy2, s_zero_GC(:,:,ii,jj)/gc_scale);
        axis([min(xl), max(xl), 0, s_ps(end)/0.001]);
        if neu_network(ii,jj)==0
            caxis([0, caxis_gc_low]);
        else
            caxis([0, caxis_gc_high]);
        end
        %shading('flat');
        shading('interp');
        colorbar();
%        title(sprintf('GC%d map %d->%d', neu_network(ii,jj), jj, ii));
        ylabel('F/0.001');
        xlabel('\mu*F/0.001');
        set(gca,'xtick', x_tick);
        set(gca,'xticklabel',x_tick_val);
        pic_name = sprintf('GC%d_map_%d_to_%d_xlog', neu_network(ii,jj), jj, ii);
        pic_output_color(pic_name);
    end
    end

    % plot network detection correctness map
    figure(8);%  set(gca, 'fontsize',font_size);
    pcolor(xx2,yy2,wrong_num);
    axis([min(xl), max(xl), 0, s_ps(end)/0.001]);
    shading('flat');
    colorbar();
    title(['wrong number (p-value=',num2str(p_value),')']);
    ylabel('F / 0.001');
    xlabel('\mu*F/0.001');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    pic_output_color('wrongNum');

    % PDC square mean of "1"
    figure(10);
    pcolor(xx2, yy2, s_pdc1_SM/gc_scale);
    axis([min(xl), max(xl), 0, s_ps(end)/0.001]);
    caxis([0, 0.1]);
    shading('flat');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    colorbar();
    ylabel('F/0.001');
    xlabel('\mu*F/0.001');
    pic_output_color('PDC1_SM');

    % PDC square mean of "0"
    figure(11);
    pcolor(xx2, yy2, s_pdc0_SM/gc_scale);
    axis([min(xl), max(xl), 0, s_ps(end)/0.001]);
    caxis([0, 0.1]);
    shading('flat');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    colorbar();
    ylabel('F/0.001');
    xlabel('\mu*F/0.001');
    pic_output_color('PDC0_SM');

    % PDC max of "1"
    figure(12);
    pcolor(xx2, yy2, s_pdc1_max);
    axis([min(xl), max(xl), 0, s_ps(end)/0.001]);
    shading('flat');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    colorbar();
    ylabel('F/0.001');
    xlabel('\mu*F/0.001');
    pic_output_color('PDC1_max');

    % PDC max of "0"
    figure(13);
    pcolor(xx2, yy2, s_pdc0_max);
    axis([min(xl), max(xl), 0, s_ps(end)/0.001]);
    shading('flat');
    set(gca,'xtick', x_tick);
    set(gca,'xticklabel',x_tick_val);
    colorbar();
    ylabel('F/0.001');
    xlabel('\mu*F/0.001');
    pic_output_color('PDC0_max');

end  % stv
end  % scee
end  % simu_time
end  % net

end % id_signature

toc();
