% Give approximation of (conditional and pairwise) GC using coef

function [gc_sapp, b12_sapp, gc_pair_sapp] = GC_sapp(A2d, De, id_x, id_y, fftlen)
  HTR = @(x) permute(conj(x), [2, 1, 3:ndims(x)]);

  [p, m] = size(A2d);
  m = round(m/p);
  id_z = 1:p;
  id_z([id_x id_y]) = [];

  A_f = fft(reshape([eye(p), A2d], p, p, []), fftlen, 3);
  Q_f = rdiv3d(HTR(A_f), De, A_f);

  % conditional GC y -> x
  a12_f = A_f(id_x, id_y, :);
  gc_sapp = a12_f ./ Q_f(id_y,id_y,:) .* conj(a12_f) / De(id_x,id_x);
  gc_sapp = mean(real(gc_sapp));
  plot(squeeze(real(gc_sapp)));

  % coef b12
  a13_f = A_f(id_x, id_z, :);
  b12_sapp_f = a12_f - rdiv3d(a13_f, Q_f(id_z,id_z,:), Q_f(id_z,id_y,:));
  b12_sapp = squeeze(ifft(b12_sapp_f, [], 3));
  % Note the later half will be non-zeros in general.
  b12_sapp = -b12_sapp(2:m+1)';

  % GC y -> x
  D_B1_sapp = mean(real(De(id_x,id_x) + rdiv3d(a13_f, Q_f(id_z,id_z,:), HTR(a13_f))));
  gc_pair_sapp = rdiv3d(b12_sapp_f, (Q_f(id_y,id_y,:) - rdiv3d(Q_f(id_y,id_z,:), Q_f(id_z,id_z,:), Q_f(id_z,id_y,:))), HTR(b12_sapp_f)) / D_B1_sapp;
  gc_pair_sapp = mean(real(gc_pair_sapp));
