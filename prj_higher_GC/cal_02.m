%
str_g_brief = @(g) sprintf('%5.2f (%5.2f)\t%5.2f (%5.2f) od=%d',...
  (g.gc(2,1)-g.od/g.len)/1e-4, g.gc(2,1)/(g.od/g.len),...
  (g.gc(1,2)-g.od/g.len)/1e-4, g.gc(1,2)/(g.od/g.len), g.od);

net_ans = [1 0];
p_val = 0.05;
b_correct_net = @(g)~any((g.gc>chi2inv(1-p_val, g.od)/g.len)(eye(g.p)==0)-net_ans');

s_kmix_short = [0.3 0.5 0.7 1.0 2.0];

cid = 4;
n_trial = 300;
correct_cnt_v   = zeros(n_trial, 1);
correct_cnt_s   = zeros(n_trial, 1);
correct_cnt_mix = zeros(n_trial, length(s_kmix_short));
for id_trial = 1:n_trial
  [Xcom, Xs, Xv] = cal_02_genX(cid);
  [p, len] = size(Xs);
  gs = cal_02_gccal(Xs);
  correct_cnt_s(id_trial) += b_correct_net(gs);
  gv = cal_02_gccal(Xv);
  correct_cnt_v(id_trial) += b_correct_net(gv);
  %fprintf('volt:\t%s\n', str_g_brief(gv)); 
  %fprintf('st:\t%s\n', str_g_brief(gs)); 

  for id_kmix = 1:length(s_kmix_short)
    kmix = s_kmix_short(id_kmix);
    X = Xcom + kmix*Xs;
    g = cal_02_gccal(X);
    correct_cnt_mix(id_trial, id_kmix) += b_correct_net(g);
    %fprintf('%5.2f\t%s\n', kmix,str_g_brief(g)); 
  end
  fprintf('id_trial = %3d\n',id_trial);
  fflush(stdout);
end

mt = cat(2, correct_cnt_v, correct_cnt_s, correct_cnt_mix);
sum(mt)
cid
num2str(100.0*sum(mt)/n_trial, '%6.1f%%')

