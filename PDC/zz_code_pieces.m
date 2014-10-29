ydir
reverse
"forward"

[xx,yy] = meshgrid(logspace(log10(1),log10(5),11), linspace(2,3,11));
zz=rand(11);
imagesc(xx,yy,zz);
set(gca, 'ydir', 'normal');

