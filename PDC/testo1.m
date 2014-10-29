%

nx = 10;
ny = 10;

rand('state',1);
xx = zeros(ny, nx);
yy = zeros(ny, nx);
for k = 1 : ny
  xx(k,:) = cumsum(rand(1,nx));
  yy(k,:) = k;
end

zz = xx+yy;
%zz = xx;

figure(1);
pcolor(xx,yy,zz);
%shading('flat');
shading('interp');
colorbar();
