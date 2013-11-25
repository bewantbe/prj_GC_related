%
pic_common_include;

new_load = 1;
if new_load
  % use case C.2c, see bignet_dense_and_sparse.pdf
  getdata_bigNet_C2c;
  network = getnetwork(netstr);
  case_st = 'C2c';
  p_EI_list = char(['E'*ones(1,pE), 'I'*ones(1,pI)]);

  %tic; od_max=50; GC_regression; toc; fflush(stdout);  % 280 sec
  tic;
  od_max = 40;
  s_od = 1:od_max;
  [oGC, oDe, R] = AnalyseSeriesFast(X, s_od);
  [aic_od, bic_od, zero_GC] = AnalyseSeries2(s_od, oGC, oDe, len);
  toc; fflush(stdout);

  tic;
  aveX = mean(X, 2);
  X = bsxfun(@minus, X, aveX);
  od = aic_od;
  srd = zeros(p,len);
  for k=1:p
    sa = ARregression(R(k,k:p:p+p*od));
    srd(k,:) = filter([1, sa], [1], X(k,:));
  end
  toc; fflush(stdout);
  tic;
  A  = ARregression(R(:,1:p+p*od));
  rd = MAfilter_v5(A, X);
  X = bsxfun(@plus, X, aveX);
  toc; fflush(stdout);

  s_id_want = [75:85];

  tic;
  % shrink dimension (RAS record)
  s_id_want_b = false(1,p);
  s_id_want_b(s_id_want) = true;
  for k=1:p
    if s_id_want_b(k)
      continue
    end
    ras(ras(:,1)==k, :) = [];
  end
  % re-label neuron index
  for k=1:length(s_id_want)
    ras(ras(:,1)==s_id_want(k)) = k;
  end
  toc; fflush(stdout);

  tic;
  % shrink dimension (voltage)
  X   = X  (s_id_want, :);
  srd = srd(s_id_want, :);
  rd  = rd (s_id_want, :);
  [p, len] = size(X);
  toc; fflush(stdout);

  sub_network = network(s_id_want, s_id_want);
  p_EI_list = p_EI_list(s_id_want);
end

p_driving = 3;
p_passive = 8;
fprintf('In network: %d->%d (%d->%d) ', p_driving, p_passive, s_id_want(p_driving), s_id_want(p_passive));
if sub_network(p_passive, p_driving)
  fprintf('true\n');
else
  fprintf('false\n');
end

ana_len = [0,5];

pic_prefix = 'pic_tmp/';
if mode_ST
  st_mode = '_ST';
  st_volt = 'SpikeTrain';
else
  st_mode = '';
  st_volt = 'Volt';
end

[tg_rd, t_rel] = spikeTriggerAve(p_driving, p_passive, ras, srd, ana_len, stv);
figure(1);
plot(0, tg_rd(t_rel==0),'rx', t_rel, tg_rd, '-+');
xlabel('t_{rel}/ms');
ylabel(sprintf('\\epsilon^{A}_{%d|%d}(t_{rel})', s_id_want(p_passive), s_id_want(p_driving)));
print('-depsc2', sprintf('%scase=%s%s_srd(%d)On%d_STA.eps',...
                 pic_prefix, case_st, st_mode, s_id_want(p_passive), s_id_want(p_driving)));

[tg_rd, t_rel] = spikeTriggerAve(p_driving, p_passive, ras, X, ana_len, stv);
figure(2);
plot(0, tg_rd(t_rel==0),'rx', t_rel, tg_rd, '-+');
xlabel('t_{rel}/ms');
ylabel(sprintf('%s_{%d|%d}(t_{rel})', st_volt, s_id_want(p_passive), s_id_want(p_driving)));
print('-depsc2', sprintf('%scase=%s%s_X(%d)On%d_STA.eps',...
                 pic_prefix, case_st, st_mode, s_id_want(p_passive), s_id_want(p_driving)));

