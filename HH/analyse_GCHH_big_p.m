% analysis single GC trial with large p
% run analyse_GC_simple.m first to get data.
% version for HH model (see gen_HH)

function analyse_GCHH_big_p(s_case, function_item, pic_prefix0, plot_settings)

% Where to save the plots
if ~exist('pic_prefix0','var') || isempty(pic_prefix0)
  pic_prefix0 = 'pic_tmp/';
end

% Set font size and line width
set(0, 'defaultfigurevisible', 'off');
if ~exist('plot_settings','var') || isempty(plot_settings)
  font_size  = get(0, 'defaultaxesfontsize');
  line_width = get(0, 'defaultlinelinewidth');
else
  font_size  = plot_settings.font_size;
  line_width = plot_settings.line_width;
  set(0, 'defaultfigurevisible', plot_settings.visible);
end

% Set items to be calculate
if exist('function_item','var') || isempty(function_item)
  auto_gc_zero_cut = function_item.auto_gc_zero_cut;
  b_output_pics    = function_item.b_output_pics;
  b_cal_net        = function_item.b_cal_net;
  b_use_pairGC     = function_item.b_use_pairGC;
  p_val            = function_item.p_val;
  gcdata_dir       = function_item.gcdata_dir;
  if isnumeric(function_item.use_od)
    f_use_od = @() function_item.use_od;
  else  % so it is char type
    est = sprintf('%s_od;', lower(function_item.use_od));
    f_use_od = @() eval(est);
  end
else
  auto_gc_zero_cut = false;  % determine the gc cut by the answer
  b_output_pics    = true;   % whether to plot and save it somewhere
  b_cal_net        = false;  % get statistics of the network
  b_use_pairGC     = false;  % use pairwise GC
  p_val            = 1e-5;   % p-value to determine the GC cut
  gcdata_dir       = 'result_GC_simple/';  % where to find GCinfoXXX.mat
  f_use_od         = @() eval('bic_od');
end

if b_cal_net
  % Load function to do the network calculation
  addpath('/home/xyy/matcode/octave-networks-toolbox');
  addpath('/home/xyy/matcode/prj_neu_smallworld');
  % Initialize the arrays to save statistics of network and dynamics
  s_stv = zeros(1, n_case);
  s_aic = zeros(1, n_case);
  s_bic = zeros(1, n_case);
  s_over= zeros(1, n_case);
  s_lack= zeros(1, n_case);
  s_CC  = zeros(1, n_case);
  s_Lu  = zeros(1, n_case);
  s_Ld  = zeros(1, n_case);
  stdat = cell(1, n_case);
end

n_case = length(s_case);

% Super big for loop
for cid = 1:n_case
  gcdata_name = s_case{cid};

  clear('b_use_spike_train');
  load([gcdata_dir, gcdata_name, '.mat']);

  neu_network = pm.net_adj;
  p = size(neu_network, 1);
  if any(diag(neu_network))
    error('neu_network: diagonal non-zero!');
  end

  % Setup output path and format
  % Note that the `st_para' will be loaded
  pic_prefix = [pic_prefix0, st_para];
  if b_use_pairGC
    pic_prefix = [pic_prefix, '_pairwise'];
  end
  pic_output       = @(st)print('-deps'  ,[pic_prefix, st, '.eps']);
  pic_output_color = @(st)print('-depsc2',[pic_prefix, st, '.eps']);
  pic_output_svg   = @(st)print('-dsvg',[pic_prefix, st, '.svg']);
  %pic_output       = @(st)print('-dpng'  ,[pic_prefix, st, '.png']);
  %pic_output_color = @(st)print('-dpng',[pic_prefix, st, '.png']);
  %pic_output       = @(st) [];
  %pic_output_color = @(st) [];
  % for save data
  pic_data_save = @(st, varargin) save('-v7', [pic_prefix, st, '.mat'], 'varargin');
  %pic_data_save = @(st, varargin) [];

  disp(pic_prefix);

  use_od = f_use_od();
  gc_zero_line = chi2inv(1-p_val, use_od)/len;
  clear('gc_zero_cut','scale_gc','s_gc_tick','s_gc_tick_white','s_gc_hist_tick','s_ISI_tick','s_ISI_tick_white');

  if b_use_pairGC
    GC = pairRGrangerT(R(:,1:(use_od+1)*p));
  else  
    GC = oGC(:,:,use_od);
  end

  % flatten the GC and connection matrix
  plain_gc = GC;
  plain_gc = plain_gc(eye(p)==0);
  plain_network = neu_network;
  plain_network = plain_network(eye(p)==0);

  % auto determine cutline
  [sorted_gc, sorted_gc_id] = sort(plain_gc);
  sorted_gc_zeroone = plain_network(sorted_gc_id);
  tmp_0 = cumsum(sorted_gc_zeroone==0);
  tmp_0 = tmp_0(end) - tmp_0;
  tmp_1 = cumsum(sorted_gc_zeroone>0);
  [~, min_err_id] = min([tmp_0; 0] + [0; tmp_1]);
  min_err_gc = sorted_gc(min_err_id);
  %disp(['min_err_gc = ', num2str(min_err_gc)]);
  p_val_min_err = 1-chi2cdf(min_err_gc*len, use_od);

  if auto_gc_zero_cut
    gc_zero_cut = min_err_gc;
    st_auto_gc1 = '';
    st_auto_gc2 = '  (in use)';
  else
    gc_zero_cut = gc_zero_line;
    st_auto_gc1 = '  (in use)';
    st_auto_gc2 = '';
  end

  if exist('s_gc_tick','var')
    s_gc_tick = s_gc_tick';
  end
  if exist('s_gc_hist_tick','var')
    s_gc_hist_tick = s_gc_hist_tick';
  end
  if exist('s_gc_tick_white','var')
    s_gc_tick_white = s_gc_tick_white';
  end
  if exist('s_ISI_tick','var')
    s_ISI_tick = s_ISI_tick';
  end
  if exist('s_ISI_tick_white','var')
    s_ISI_tick_white = s_ISI_tick_white';
  end
  %neu_network_guess = gc_prob_nonzero(GC,use_od,len) >= 1 - p_val;
  neu_network_guess = GC >= gc_zero_cut;
  adj_cmp = neu_network_guess - neu_network;

  fprintf('mean ISI = %.2f (std=%.2f)\n', mean(ISI), std(ISI));
  disp(['aic_od = ',num2str(aic_od)]);
  disp(['bic_od = ',num2str(bic_od)]);
  disp(['use_od = ',num2str(use_od)]);
  mean_gc0 = mean(GC(neu_network==0));  %TODO: Seems a bug here, the diagonal
  var_gc0  = var (GC(neu_network==0));
  var_theo_gc0 = 2*use_od/len^2 + 4/len*(mean_gc0-use_od/len);
  mean_gc1 = mean(GC(neu_network~=0));
  var_gc1  = var (GC(neu_network~=0));
  var_theo_gc1 = 2*use_od/len^2 + 4/len*(mean_gc1-use_od/len);

  fprintf('data length: %.2e\n', len);
  scale_gc = 1e-4;
  if scale_gc~=0
  fprintf('mean GC0/%.1e: %.2f  (stdv=%.2f theo: %.2f res stdv=%.2f)\n',...
          scale_gc, mean_gc0/scale_gc, sqrt(var_gc0)/scale_gc,...
          sqrt(var_theo_gc0)/scale_gc, sqrt(var_gc0-var_theo_gc0)/scale_gc);
  fprintf('mean GC1/%.1e: %.2f  (stdv=%.2f theo: %.2f res stdv=%.2f)\n',...
          scale_gc, mean_gc1/scale_gc, sqrt(var_gc1)/scale_gc,...
          sqrt(var_theo_gc1)/scale_gc, sqrt(var_gc1-var_theo_gc1)/scale_gc);

  stdat{cid} = sprintf('%.2f  %.2f  %.2f  %.2f  %.2f  %.2f  %.2f\n',...
          use_od/len/scale_gc,...
          mean_gc0/scale_gc, mean_gc1/scale_gc, sqrt(var_gc0)/scale_gc,...
          sqrt(var_theo_gc0)/scale_gc, sqrt(var_gc1)/scale_gc,...
          sqrt(var_theo_gc1)/scale_gc);
  else
  fprintf('mean GC0: %.2e  (stdvar=%.2e, theo: %.2e)  res stdvar=%.2e\n',...
          mean_gc0, sqrt(var_gc0), sqrt(var_theo_gc0),...
          sqrt(var_gc0-var_theo_gc0));
  fprintf('mean GC1: %.2e  (stdvar=%.2e, theo: %.2e)  res stdvar=%.2e\n',...
          mean_gc1, sqrt(var_gc1), sqrt(var_theo_gc1),...
          sqrt(var_gc1-var_theo_gc1));
  end
  fprintf('   ratio: %.2f\n', mean_gc1/mean_gc0);
  fprintf('Ideal GC0 = %.2e\n', use_od/len);
  fprintf('GC(P=%.2e) = %.2e%s\n',...
          p_val,         gc_zero_line, st_auto_gc1);
  fprintf('GC(P=%.2e) = %.2e  (least wrong edges)%s\n',...
          p_val_min_err, min_err_gc,   st_auto_gc2);

  n_over = sum((adj_cmp(:)==1));
  n_lack = sum((adj_cmp(:)==-1));
  n_conn = sum(neu_network(:));
  disp(['over guess: ', num2str(n_over)]);
  disp(['lack guess: ', num2str(n_lack)]);
  fprintf('connection: %d / %d = %.1f%%\n', n_conn, p*(p-1),...
          100*n_conn/(p*(p-1)));
  disp(['overall correctness: ', num2str(100*(1-(n_over+n_lack)/(p*(p-1))))]);
  
  fprintf('==== %d / %d, %.2f / %.2f, %.1f\n', bic_od, aic_od, mean_gc0/scale_gc,...
          use_od/len/scale_gc, 100*(1-(n_over+n_lack)/(p*(p-1))));

  if b_cal_net
    addpath('/home/xyy/matcode/octave-networks-toolbox');
    addpath('/home/xyy/matcode/prj_neu_smallworld');
    s_Ld(cid) = avePathLength(neu_network_guess);
    s_Lu(cid) = avePathLength((neu_network_guess+neu_network_guess.')>0);
    s_CC(cid) = clustering_coef_BDN(neu_network_guess);
    s_over(cid) = n_over;
    s_lack(cid) = n_lack;
    s_stv(cid)  = pm.stv;
    s_aic(cid)  = aic_od;
    s_bic(cid)  = bic_od;
  end

  if b_output_pics
    % show histogram of ISI
    figure(1);  set(gca,'fontsize',font_size);
    hist(ISI, 20);
    ylabel('count');
    xlabel('ave ISI of each neuron (ms)');
    if exist('s_ISI_tick','var') && ~isempty(s_ISI_tick)
      set(gca,'xtick',[s_ISI_tick; s_ISI_tick_white],'xticklabel',[num2str(s_ISI_tick); char(32*ones(length(s_ISI_tick_white),1))]);
    end
    pic_output_color('_ISI_hist');

    % show true adjacency matrix
    [xx,yy] = meshgrid(0:p, 0:p);
    figure(2);  set(gca,'fontsize',font_size);
    colormap(fliplr(gray()')');
    shading('faceted');
    %hd=pcolor(xx,yy,[[flipud(neu_network); zeros(1,p)],zeros(p+1,1)]);
    pcolor(xx,yy,[[neu_network; zeros(1,p)],zeros(p+1,1)]);
    hd=colorbar();
    set(hd,'fontsize',font_size);
    set(hd,'ytick',[0;0.25;0.5;0.75;1],'yticklabel',['0  ';'   ';'0.5';'   ';'1.0']);
    %axis('square','off');
    xlabel('index of driven one');
    ylabel('index of passive one');
    set(gca,'xtick',[1 50 100]);
    set(gca,'ytick',[1 50 100]);
    pic_output('_gcadj_ans');

    % show GC adjacency matrix (gray points)
    figure(3);  set(gca,'fontsize',font_size);
    colormap(fliplr(gray()')');
    shading('faceted');
    adj_gc = zero_GC/scale_gc;
    adj_gc(adj_gc<0) = 0;
    %hd=pcolor(xx,yy,[[flipud(adj_gc); zeros(1,p)],zeros(p+1,1)]);
    pcolor(xx,yy,[[adj_gc; zeros(1,p)],zeros(p+1,1)]);
    %caxis([0,2]);
    hd=colorbar();
    %set(hd,'ylabel','GC');
    set(hd,'fontsize',font_size);
    %set(hd,'ytick',s_gc_tick);
    if exist('s_gc_tick','var') && ~isempty(s_gc_tick)
      set(hd,'ytick',[s_gc_tick; s_gc_tick_white],'yticklabel',[num2str(s_gc_tick); char(32*ones(length(s_gc_tick_white),1))]);
    end
    %axis('square','off');
    xlabel('index of driven one');
    ylabel('index of passive one');
    set(gca,'xtick',[1 50 100]);
    set(gca,'ytick',[1 50 100]);
    %zlabel('GC value (10^{',num2str(round(log10(scale_gc))),'})');
    pic_output('_gcadj');

    % show correctness by color map
    figure(4);  set(gca,'fontsize',font_size);
    shading('faceted');
    %pcolor(xx,yy,[[flipud(adj_cmp); zeros(1,p)],zeros(p+1,1)]);
    pcolor(xx,yy,[[adj_cmp; zeros(1,p)],zeros(p+1,1)]);
    caxis([-1,1]);
    hd=colorbar();
    set(hd,'fontsize',font_size);
    %axis('square','off');
    xlabel('index of driven one');
    ylabel('index of passive one');
    set(gca,'xtick',[1 50 100]);
    set(gca,'ytick',[1 50 100]);
    pic_output_color('_adj_cmp');

    % show sorted GC values
    figure(5);  set(gca,'fontsize',font_size);
    hd=plot([1,(p*p-p)]/10^3, [gc_zero_line, gc_zero_line]/scale_gc, 'b-',...
            [1,(p*p-p)]/10^3, [  min_err_gc,   min_err_gc]/scale_gc, 'r--',...
            (1:(p*p-p))/10^3, sort(plain_gc)/scale_gc, 'k.');
    set(hd,'linewidth',line_width);
    xlabel('sorted index (10^3)');
    ylabel(['GC value (10^{',num2str(round(log10(scale_gc))),'})']);
    %set(gca,'ytick',s_gc_tick);
    if exist('s_gc_tick','var') && ~isempty('s_gc_tick')
      set(gca,'ytick',[s_gc_tick; s_gc_tick_white],'yticklabel',[num2str(s_gc_tick); char(32*ones(length(s_gc_tick_white),1))]);
    end
    hd=legend(['GC0\neq0 P-value = ',num2str(p_val)], 'best 0 or 1 threshold',...
              'location','northwest');
    set(hd,'fontsize',font_size-6);
    pic_output_color('_gc_sort');
    pic_data_save('_gc_sort', p, use_od, len, plain_gc, plain_network);

    % show histogram of GC values
    figure(6);
    if exist('OCTAVE_VERSION', 'builtin')
      old_gnuterm = getenv('GNUTERM');
      setenv('GNUTERM','qt');
    end
    clf;  set(gca,'fontsize',font_size);
    hold('on');
    [nn,xx] = hist(plain_gc/scale_gc,100);
    % crop the bars which are too high
    peak_nn = max(nn(20:end));
    line_high = peak_nn;
    peak_scale = 10^floor(log10(1.3*peak_nn));
    peak_scale = ceil(4*1.3*peak_nn/peak_scale)/4*peak_scale;
    nn_id = 1;
    while nn(nn_id)>peak_scale
      disp(['bin[',num2str(nn_id),']=',num2str(nn(nn_id))]);
      line_high = peak_scale;
      nn_id = nn_id + 1;
    end

    nn_GC_E = hist(GC(neu_network(:,1:pm.nE)==1)/scale_gc, xx);
    tmp_gc = GC(:,1+pm.nE:p)
    nn_GC_I = hist(tmp_gc(neu_network(:,1+pm.nE:p)==1)/scale_gc, xx);
    %nn_GC_I = hist(GC(:,1+pm.nE:p)(neu_network(:,1+pm.nE:p)==1)/scale_gc, xx);
    nn_GC_0 = hist(GC(neu_network()==0 & eye(p)==0)/scale_gc, xx);
    %bar(xx,nn, 'facecolor',[0.5,0.5,0.5],'linestyle','-');
    shading('flat');
    bar(xx, nn_GC_0, 1.0, 'facecolor',[0.5,0.5,0.5]);
    bar(xx, nn_GC_I, 1.0, 'facecolor',[0.0,0.0,0.9]);
    bar(xx, nn_GC_E, 1.0, 'facecolor',[0.9,0.0,0.0]);
    set(findobj(gca,'Type','patch'), 'facealpha', 0.5);
    xlabel(['GC value (10^{',num2str(round(log10(scale_gc))),'})']);
    ylabel('count/bin');
    %set(gca, 'xtick',s_gc_tick);
    if exist('s_gc_tick','var') && ~isempty('s_gc_tick')
      set(gca,'xtick',[s_gc_tick; s_gc_tick_white],'xticklabel',[num2str(s_gc_tick); char(32*ones(length(s_gc_tick_white),1))]);
    end
    if exist('s_gc_hist_tick','var') && ~isempty('s_gc_hist_tick')
      set(gca,'ytick',s_gc_hist_tick);
    end
    hd=plot([gc_zero_line,gc_zero_line]/scale_gc, [0,line_high],'g-',...
            [  min_err_gc,  min_err_gc]/scale_gc, [0,line_high],'r--');
    set(hd,'linewidth',line_width);
    if line_high == peak_scale
      sa=axis();  sa(4)=line_high;  axis(sa);
    end
    hd=legend('','','',['H0 P-value = ',num2str(p_val)], 'best 0 or 1 threshold');
    set(hd,'fontsize',font_size-4);
    hold('off');
    if exist('OCTAVE_VERSION', 'builtin')
      pic_output_svg('_gc_hist');
      setenv('GNUTERM', old_gnuterm);
    else
      pic_output_color('_gc_hist');
    end

  end  %if b_output_pics

end %for case_th

if b_cal_net
  fprintf('stv, bic_od(aic_od), H0 mean, H0 mean, mean(GC0), mean(GC1), std(GC0), std(GC0_H0), std(GC1), std(GC1_H0)\n');
  for id=1:length(stdat)
    fprintf('%.1f  %d(%d)  %s', s_stv(id), s_bic(id), s_aic(id), stdat{id});
  end

  fprintf('stv, bic_od(aic_od), over, lack, L_dir, L_undir, CC\n');
  for id=1:length(s_CC)
    fprintf('%.1f  %d(%d)  %d  %d  %.2f  %.2f  %.3f\n',...
            s_stv(id), s_bic(id), s_aic(id), s_over(id), s_lack(id), s_Ld(id), s_Lu(id), s_CC(id));
  end
end
