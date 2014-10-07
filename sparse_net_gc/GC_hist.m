
function GC_hist(GC, neu_network, nE)
scale_gc = 1e-4;
line_width = 2;
font_size = 18;

p = size(GC,1);
plain_gc = GC;
plain_gc = plain_gc(eye(p)==0);

% show histogram of GC values
clf;  set(gca,'fontsize',font_size);
hold('on');
[nn,xx] = hist(plain_gc/scale_gc,100);
% crop the bars which are too high
peak_nn = max(nn(20:end));
line_high = peak_nn;
peak_scale = 10^floor(log10(1.3*peak_nn));
peak_scale = ceil(4*1.3*peak_nn/peak_scale)/4*peak_scale;
nn_id = 1;
while nn(nn_id)>peak_scale
  disp(['bin[',num2str(nn_id),']=',num2str(nn(nn_id))]);
  line_high = peak_scale;
  nn_id = nn_id + 1;
end

nn_GC_E = hist(GC(neu_network(:,1:nE)==1)/scale_gc, xx);
nn_GC_I = hist(GC(:,1+nE:p)(neu_network(:,1+nE:p)==1)/scale_gc, xx);
nn_GC_0 = hist(GC(neu_network()==0 & eye(p)==0)/scale_gc, xx);
%bar(xx,nn, 'facecolor',[0.5,0.5,0.5],'linestyle','-');
shading('flat');
bar(xx, nn_GC_0, 1.0, 'facecolor',[0.5,0.5,0.5]);
bar(xx, nn_GC_I, 1.0, 'facecolor',[0.0,0.0,0.9]);
bar(xx, nn_GC_E, 1.0, 'facecolor',[0.9,0.0,0.0]);
set(findobj(gca,'Type','patch'), 'facealpha', 0.5);
xlabel(['GC value (10^{',num2str(round(log10(scale_gc))),'})']);
ylabel('count/bin');
hold('off');

