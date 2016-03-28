%

qyy_f = Q_f(id_y,id_y,:);

qyy_line = ifft(qyy_f(:)');
qyy_line = qyy_line(1:m);

Qyy_sapp = R2covz(qyy_line);

figure(20); imagesc(Qyy_mapp);
figure(21); imagesc(Qyy_sapp);

figure(22); imagesc(Qyy_mapp - Qyy_sapp); colorbar(); caxis([-1 1]*1e-2);

figure(13); plot(qyy_line); ylim([-1 1]*0.1);

  M_c = zeros(size(M));
  for k=1:m
    M_c((k-1)*p+1:k*p, 1:k*p) = A2d(:,(m-k)*p+1:end);
  end
  M_c  = M_c (id_bt2tb, id_bt2tb);

  Qyy_app_diff = M_c(:, id_by)'*iG*M_c(:, id_by);

figure(23);
imagesc(Qyy_app_diff);
colorbar(); caxis([-1 1]*1e-2);

% cool! Impossible!
figure(24);
imagesc(Qyy_app_diff + Qyy_mapp - Qyy_sapp);
colorbar(); caxis([-1 1]*1e-13);
maxerr(Qyy_app_diff + Qyy_mapp - Qyy_sapp)


figure(25);
imagesc(Qyy_app_diff - ((M(:, id_by)+M_c(:, id_by))'*iG*(M(:, id_by)+M_c(:, id_by))));
colorbar(); caxis([-1 1]*1e-13);

