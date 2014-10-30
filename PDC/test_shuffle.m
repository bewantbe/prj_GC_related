%
fontsize = 20;
linewidth = 3;
set(0, 'defaultlinelinewidth', linewidth);
set(0, 'defaultaxesfontsize', fontsize);
pic_prefix = 'pic_tmp/';
pic_output       = @(st)print('-deps',  [pic_prefix, st, '.eps']);
pic_output_color = @(st)print('-depsc2',[pic_prefix, st, '.eps']);

pm = [];
pm.neuron_model = 'LIF';
pm.net  = 'net_2_2';
pm.scee = 0.05;
pm.pr   = 1.0;
pm.ps   = 0.012;
pm.t    = 1e5;
pm.seed = 'auto';
pm.extra_cmd = '-q';

n_trials = 100;
n_div = 10;
p = 2;
fftlen = 1024;
nv = p * (p-1);
s_PDC_SM  = zeros(nv, n_trials);
s_PDC_max = zeros(nv, n_trials);
s_PDC_plain_abs = zeros(nv, fftlen, n_trials);
s_GC_plain = zeros(nv, n_trials);

for k = 1 : n_trials
  X = gen_HH(pm, 'rm');
  m = chooseOrderAuto(X);
  pdc = PDC(X, m, fftlen);
  pdc_plain = reshape(pdc, p*p, []);
  pdc_plain(eye(p)==1, :) = [];
  s_PDC_SM (:, k) = real(mean(pdc_plain, 2));
  s_PDC_max(:, k) = max(abs(pdc_plain), [], 2);
  s_PDC_plain_abs(:, :, k) = abs(pdc_plain);
  gc  = nGrangerT(X,m);
  s_GC_plain(:, k) = gc(eye(p)==0);
end

save('-v7', 'test_shuffle_no.mat', 'pm', 's_PDC_SM', 's_PDC_max', 's_PDC_plain_abs', 's_GC_plain');

figure(1);
hist(s_GC_plain(1,:),n_div);
pic_output_color('s_GC_plain_1');

figure(2);
hist(s_GC_plain(2,:),n_div);
pic_output_color('s_GC_plain_2');

X = gen_HH(pm, 'rm');

s_sh_PDC_SM  = zeros(nv, n_trials);
s_sh_PDC_max = zeros(nv, n_trials);
s_sh_PDC_plain_abs = zeros(nv, fftlen, n_trials);
s_sh_GC_plain = zeros(nv, n_trials);
for k = 1 : n_trials
  X = shuffleData(X);
  m = chooseOrderAuto(X);
  pdc = PDC(X, m, fftlen);
  pdc_plain = reshape(pdc, p*p, []);
  pdc_plain(eye(p)==1, :) = [];
  s_sh_PDC_SM (:, k) = real(mean(pdc_plain, 2));
  s_sh_PDC_max(:, k) = max(abs(pdc_plain), [], 2);
  s_sh_PDC_plain_abs(:, :, k) = abs(pdc_plain);
  gc  = nGrangerT(X,m);
  s_sh_GC_plain(:, k) = gc(eye(p)==0);
end

save('-v7', 'test_shuffle_sh.mat', 'pm', 's_sh_PDC_SM', 's_sh_PDC_max', 's_sh_PDC_plain_abs', 's_sh_GC_plain');
figure(3);
hist(s_sh_GC_plain(1,:),n_div);
pic_output_color('s_sh_GC_plain_1');
figure(4);
hist(s_sh_GC_plain(2,:),n_div);
pic_output_color('s_sh_GC_plain_2');

s_shm_PDC_SM  = zeros(nv, n_trials);
s_shm_PDC_max = zeros(nv, n_trials);
s_shm_PDC_plain_abs = zeros(nv, fftlen, n_trials);
s_shm_GC_plain = zeros(nv, n_trials);
m = 17;
for k = 1 : n_trials
  X = shuffleData(X);
  pdc = PDC(X, m, fftlen);
  pdc_plain = reshape(pdc, p*p, []);
  pdc_plain(eye(p)==1, :) = [];
  s_shm_PDC_SM (:, k) = real(mean(pdc_plain, 2));
  s_shm_PDC_max(:, k) = max(abs(pdc_plain), [], 2);
  s_shm_PDC_plain_abs(:, :, k) = abs(pdc_plain);
  gc  = nGrangerT(X,m);
  s_shm_GC_plain(:, k) = gc(eye(p)==0);
end

save('-v7', 'test_shuffle_shm.mat', 'pm', 's_shm_PDC_SM', 's_shm_PDC_max', 's_shm_PDC_plain_abs', 's_shm_GC_plain');
figure(5);
hist(s_shm_GC_plain(1,:),n_div);
pic_output_color('s_shm_GC_plain_1');
figure(6);
hist(s_shm_GC_plain(2,:),n_div);
pic_output_color('s_shm_GC_plain_2');

