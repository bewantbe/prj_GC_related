%

p = 200;
rand('state', 1);
neu_network = rand(p) < 0.5;

[xx,yy] = meshgrid(0:p, 0:p);
figure(2);
%hd=pcolor(xx,yy,[[flipud(neu_network); zeros(1,p)],zeros(p+1,1)]);
pcolor(xx,yy,[[neu_network; zeros(1,p)],zeros(p+1,1)]);
% bug:
print('-depsc2', 'pic_tmp/fjksadl.eps');

% workaround
figure(3);
imagesc(neu_network);
%set(gca,'xgrid', 'on', 'ygrid', 'on'

%grid on
%print('-depsc2', 'pic_tmp/fjksadl2.eps');
%set(gca,'XMinorGrid','on')
%print('-depsc2', 'pic_tmp/fjksadl3.eps');

%set(gca,'xgrid', 'on', 'ygrid', 'on', 'gridlinestyle', '-', 'xcolor', 'k', 'ycolor', 'k');

line(0.5+[zeros(p+1,1), p*ones(p+1,1)]', 0.5+[1;1]*(0:p), 'color', 'k');
line(0.5+[1;1]*(0:p), [zeros(p+1,1), 0.5+p*ones(p+1,1)]', 'color', 'k');

print('-depsc2', 'pic_tmp/fjksadl2.eps');

