% 

function gc_zero_cut = gc_pval_choose(GC, use_od, neu_network, p, len, p_val, auto_gc_zero_cut)
  gc_zero_line = chi2inv(1-p_val, use_od)/len;

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

  fprintf('Ideal GC0 = %.2e\n', use_od/len);
  fprintf('GC(P=%.2e) = %.2e%s\n',...
          p_val,         gc_zero_line, st_auto_gc1);
  fprintf('GC(P=%.2e) = %.2e  (least wrong edges)%s\n',...
          p_val_min_err, min_err_gc,   st_auto_gc2);

