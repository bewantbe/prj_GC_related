% 
pic_common_include;
%TODO: improve average_volt.m

mode_ST = 1;

new_load = 0;
if new_load
  new_load = 0;
  clear('X','ras','srd','rd');
  case_st = 'C.2a';
  switch case_st
  case 'C.1a'
    p=100;  stv=0.5;  fn='data/volt_net_100_20_p[80,20]_sc=[0.005,0.005,0.007,0.007]_pr=1_ps=0.012_t=1.00e+06_stv=0.5.dat';
    fras = 'data/RAS_net_100_20_p[80,20]_sc=[0.005,0.005,0.007,0.007]_pr=1_ps=0.012_t=1.00e+06_stv=0.5.txt';
    network = getnetwork('net_100_20');
  case 'C.2a'
    p=100;  stv=0.5;  fn='data/volt_net_100_21_p[80,20]_sc=[0.005,0.005,0.007,0.007]_pr=1_ps=0.012_t=1.00e+06_stv=0.5.dat';
    fras = 'data/RAS_net_100_21_p[80,20]_sc=[0.005,0.005,0.007,0.007]_pr=1_ps=0.012_t=1.00e+06_stv=0.5.txt';
    network = getnetwork('net_100_21');
  case 'C.3a'
    p=100;  stv=0.5;  fn='data/volt_net_100_01_p[80,20]_sc=[0.006,0.006,0.006,0.006]_pr=0.24_ps=0.02_t=1.00e+06_stv=0.5.dat';
    fras = 'data/RAS_net_100_01_p[80,20]_sc=[0.006,0.006,0.006,0.006]_pr=0.24_ps=0.02_t=1.00e+06_stv=0.5.txt';
    network = getnetwork('net_100_01');
  case 'C.4a'
    p=100;  stv=0.5;  fn='data/volt_net_100_20_p[80,20]_sc=[0.006,0.006,0.006,0.006]_pr=0.24_ps=0.02_t=1.00e+06_stv=0.5.dat';
    fras = 'data/RAS_net_100_20_p[80,20]_sc=[0.006,0.006,0.006,0.006]_pr=0.24_ps=0.02_t=1.00e+06_stv=0.5.txt';
    network = getnetwork('net_100_20');
  case 'C.5a'
    p=100;  stv=0.5;  fn='data/volt_net_100_21_p[80,20]_sc=[0.006,0.006,0.006,0.006]_pr=0.24_ps=0.02_t=1.00e+06_stv=0.5.dat';
    fras = 'data/RAS_net_100_21_p[80,20]_sc=[0.006,0.006,0.006,0.006]_pr=0.24_ps=0.02_t=1.00e+06_stv=0.5.txt';
    network = getnetwork('net_100_21');
  otherwise
    error('no this cases');
  end

  s_id_want = [75:85];

  %X = zeros(length(s_id_want), 0);
  %len_xblock = round(2^29/8/p);
  %fid=fopen(fn,'r');
  %while true
    %X0=fread(fid,[p,len_xblock],'double');
    %if isempty(X0)
      %break;
    %end
    %X = [X, X0(s_id_want, :)];
    %clear('X0');
  %end
  %fclose(fid);

  tic; fid=fopen(fn,'r'); X=fread(fid,[p,inf],'double'); fclose(fid); toc; fflush(stdout);  % 14 sec

  tic; ras = load('-ascii', fras);  toc; fflush(stdout);  % 17 sec (depends on spikes)

  if mode_ST
    tic;
    % convert to spike train
    len = size(X, 2);
    for neuron_id = 1:p
      st = SpikeTrain(ras, len, neuron_id, 1, stv);
      X(neuron_id,:) = st;
    end
    toc; fflush(stdout);  % 5 sec
  end

  tic; od_max=50; GC_regression; toc; fflush(stdout);  % 280 sec

  tic;
  % delete unwanted RAS record
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
  % shrink dimension
  X   = X  (s_id_want, :);
  srd = srd(s_id_want, :);
  rd  = rd (s_id_want, :);
  [p, len] = size(X);
  toc; fflush(stdout);

  sub_network = network(s_id_want, s_id_want);
end

p_driving = 8;
p_passive = 6;
fprintf('In network: %d->%d (%d->%d) ', p_driving, p_passive, s_id_want(p_driving), s_id_want(p_passive));
if sub_network(p_passive, p_driving)
  fprintf('true\n');
else
  fprintf('false\n');
end

ana_len = 200;

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
print('-depsc2', sprintf('%scase=%s%s_srd(%d)On%d_STC.eps',...
                 pic_prefix, case_st, st_mode, s_id_want(p_passive), s_id_want(p_driving)));

[tg_rd, t_rel] = spikeTriggerAve(p_driving, p_passive, ras, X, ana_len, stv);
figure(2);
plot(0, tg_rd(t_rel==0),'rx', t_rel, tg_rd, '-+');
xlabel('t_{rel}/ms');
ylabel(sprintf('%s_{%d|%d}(t_{rel})', st_volt, s_id_want(p_passive), s_id_want(p_driving)));
print('-depsc2', sprintf('%scase=%s%s_X(%d)On%d_STC.eps',...
                 pic_prefix, case_st, st_mode, s_id_want(p_passive), s_id_want(p_driving)));


network(s_id_want(p_passive), s_id_want(p_driving))
oGC(s_id_want(p_passive), s_id_want(p_driving), bic_od)
nGrangerT(X([p_driving, p_passive], :), bic_od)
%nGrangerT(srd([p_driving, p_passive], :), aic_od)

