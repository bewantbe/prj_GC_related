% Test where is the error

pow2ceil = @(x) 2^ceil(log2(x));
maxerr = @(x) max(abs(x(:)));

fit_od = 40;
use_od = 200;
m = use_od;

%ed = 0;
if ~exist('ed', 'var') || isempty(ed) || ~ed
  ed = true;

  %gen_data_n10_c1;
  %gen_data_n40_c1;  % 1 40
  gen_data_n100_c1;  % 32  32

  len = size(X,2);

  tic
  covz = getcovzpd(X, fit_od);  clear X
  toc
  [A2d, De] = ARregressionpd(covz, p);  clear covz
  
%  fa = sqrt(1/0.7);
%	De = [1.0, 0.4*fa; 0.4*fa, 1.0];
%	A2d = [-0.8,-0.16*fa, 0.5, 0.2*fa;
%		     0.0/fa, -0.9, 0.0/fa, 0.5];
%	p = size(A,1);

  S = A2S(A2d, De, max(pow2ceil(8*use_od), 1024));
%  S = StdWhiteS(S);
  R = S2cov(S, use_od);
  tic
  [GC De A2d] = RGrangerTfast(R);
  toc
end

% GC verification
id_y = 0;
while (id_y < 20)
id_x = 2;
id_y = id_y + 1;
%id_x = 1;
%id_y = 2;

fprintf('Number of variates: %d\n', p);
fprintf('Extended fitting order: %d\n', m);
fprintf('Net edge(%d, %d) = %d\n', id_x, id_y, pm.net_adj(id_x, id_y));
fprintf('GC : %.2e\n', GC(id_x, id_y));

%{
  % ====== triangle matrix way =======
  [p, m] = size(A2d);
  m = m/p;

  % Construct M and inverse G matrix
  A2d_I = [eye(p) A2d(:, 1:end-p)];
  invDe = inv(De);
  tic
  M = zeros(p*m, p*m);
  iG = sparse(p*m, p*m);
  for k=0:m-1
    M(k*p+1:(k+1)*p, k*p+1:end) = A2d_I(:,1:end-k*p);
    iG(k*p+1:(k+1)*p, k*p+1:(k+1)*p) = invDe;
  end

  % Blocked toeplitz matrix to toeplitz-block blocked matrix
  id_bt2tb = reshape(1:p*m, p, [])';
  M  = M (id_bt2tb, id_bt2tb);
  iG = iG(id_bt2tb, id_bt2tb);

  % index for indexing variates x,y,z
  id_bx = (1:m) + (id_x-1)*m;
  id_by = (1:m) + (id_y-1)*m;
  id_bz = 1:p*m;
  id_bz([id_bx id_by]) = [];

  a12 = -A2d(id_x, id_y:p:end);  % coef: id_y -> id_x

  % Conditional GC y -> x
  Qyy_mapp = M(:, id_by)'*iG*M(:, id_by);
  gc_mapp = a12 / Qyy_mapp * a12' / De(id_x,id_x);

  toc;
%}
  % ======= spectrum way =========
  fftlen  = 1024;
  HTR = @(x) permute(conj(x), [2, 1, 3:ndims(x)]);

  [p, m] = size(A2d);
  m = round(m/p);
  id_z = 1:p;
  id_z([id_x id_y]) = [];

  tic
  A_f = fft(reshape([eye(p), A2d], p, p, []), fftlen, 3);
  Q_f = rdiv3d(HTR(A_f), De, A_f);
  toc

  % conditional GC y -> x
  a12_f = A_f(id_x, id_y, :);
  gc_sapp_f = squeeze(real(a12_f ./ Q_f(id_y,id_y,:) .* conj(a12_f) / De(id_x,id_x)));
  gc_sapp = mean(gc_sapp_f);

  figure(2); plot(squeeze(gc_sapp_f));


  % Show diff
  sq = @squeeze;

  figure(10);  plot(sq(S(id_y,id_y,:)));
  figure(11);  plot(sq(S(id_x,id_x,:)));

  % frequency GC
  tic
  [D, De0_star] = ARregression(R((1:p)~=id_y, mod(1:end, p)~=mod(id_y,p)));
%  [B, De0     ] = ARregression(R);
  B = A2d;  De0 = De;
  toc; tic
  wGc = singleGrangerFA(D, De0_star, B, De0, id_y, id_x, fftlen);
  toc

  fq = 0:fftlen-1;
  figure(2); plot(fq, wGc, fq, gc_sapp_f); legend('fgc', 'sapp');
  figure(3); plot(wGc, gc_sapp_f, [0 max(wGc)], [0 max(wGc)]); hold on;
%  figure(4); plot(wGc, 1 ./(1 ./gc_sapp_f-1), [0 max(wGc)], [0 max(wGc)]);
end
