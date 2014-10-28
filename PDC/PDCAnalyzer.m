% partial coherence demo

function [mean_sqr_pdc, pdc, mean_sqr_dtf, dtf] = PDCAnalyzer(X, is_plot)
if ~exist('is_plot','var')
  is_plot = 0;
end
fftlen = 1024;
p = size(X, 1);
m = chooseOrderAuto(X);

pdc = PDC(X, m, fftlen);

f_mean_sqr = @(c) real(mean( c.*conj(c), 3 ));
mean_sqr_pdc = f_mean_sqr(pdc);

fqn = 1:fftlen/2;
fqs = fqn / fftlen;

if is_plot == 1 || is_plot == 3
  global g_figure_id
  if ~isempty(g_figure_id)
    figure(g_figure_id + 1);
  else
    figure(91);
  end
  for j = 1 : p
    for k = 1 : p
      subplot(p,p,(j-1)*p+k);
      plot(fqs, abs(squeeze(pdc(j,k,fqn))));
      axis([0, 0.5, 0, 1]);
      set(gca, 'XTickLabel','');
      set(gca, 'XTick', []);
      set(gca, 'YTickLabel','');
      set(gca, 'YTick', []);
    end
  end
end

dtf = DTF(X, m, fftlen);
if is_plot == 2 || is_plot == 3

  global g_figure_id
  if ~isempty(g_figure_id)
    figure(g_figure_id + 2);
  else
    figure(92);
  end
  for j = 1 : p
    for k = 1 : p
      subplot(p,p,(j-1)*p+k);
      plot(fqs, abs(squeeze(dtf(j,k,fqn))));
      axis([0, 0.5, 0, 1]);
      set(gca, 'XTickLabel','');
      set(gca, 'XTick', []);
      set(gca, 'YTickLabel','');
      set(gca, 'YTick', []);
    end
  end
end

mean_sqr_dtf = f_mean_sqr(dtf);

%
%xx = zeros(p, fftlen);
%for j = 1 : p
%  for k = 1 : p
%    xx(j,:) += abs(squeeze(dtf(j,k,:))'.^2);
%  end
%end
%figure(3);
%plot(xx');

