% Do a basic GC analysis, then save the result to a file
% note: pm should in a full input form

function [zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od, pm, b_use_spike_train, ISI, file_suffix, path_prefix)
if ~exist('fflush','builtin')
  fflush = @(s) 0;
end

[p,len] = size(X);

tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Basic GC analysis
s_od = 1:max_od;
if p<100
  [oGC, oDe, R] = AnalyseSeriesFast(X, s_od);
else
  [oGC, oDe, R] = AnalyseSeriesLevinson(X, s_od);
end
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
%save('-v6','tmp_gc.mat','p','len','s_od','oGC','oDe','R');
fprintf('t = %6.3fs cal GC.\n', toc());

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print out data
if ~exist('pm','var')
fprintf('bo:%2d, ao:%2d\n', bic_od, aic_od);
disp('var (\Sigma) at bic_od:');
disp(oDe(:,:,bic_od));
format 'bank'
  disp('GC(od=20)*1e4:');
  disp(1e4*oGC(:,:,20));
  disp(['GC(od=', num2str(bic_od), ')*1e4:']);
  disp(1e4*oGC(:,:,bic_od));
  disp(['GC(od=', num2str(aic_od), ')*1e4:']);
  disp(1e4*oGC(:,:,aic_od));
  disp('GC(od=zero)*1e4:');
  disp(1e4*zero_GC);
fflush(stdout);
  disp('non-zero test (at bic_od):');
  disp(gc_prob_nonzero(oGC(:,:,bic_od),bic_od,len));
  disp('non-zero test (at aic_od):');
  disp(gc_prob_nonzero(oGC(:,:,aic_od),aic_od,len));
  disp('confidence intervals (at bic_od):');
  [gc_lower, gc_upper] = gc_prob_intv(oGC(:,:,bic_od), bic_od, len);
  disp('lower*1e4:');
  disp(gc_lower*1e4);
  disp('upper*1e4:');
  disp(gc_upper*1e4);
format 'short'
disp('var ratio (at bic_od): var(x)/var(\epsilon), var(y)/var(\eta)');   % for 2-var only
disp([num2str(R(1,1)/oDe(1,1,bic_od)), ' ', num2str(R(2,2)/oDe(2,2,bic_od))]);
fflush(stdout);
end

% plot GC(od)
%{
rg = 34:99;
gc_scale = 1e-4;
figure(1);
%plot(s_od(rg), squeeze(oGC(1,2,rg))/gc_scale);
plot(s_od(rg), (squeeze(oGC(1,2,rg)) - s_od(rg)'/len)/gc_scale);
figure(2);
%plot(s_od(rg), squeeze(oGC(2,1,rg))/gc_scale)
plot(s_od(rg), (squeeze(oGC(2,1,rg)) - s_od(rg)'/len)/gc_scale)
%}

rg = s_od;
gc_scale = 1e-4;
figure(1);
plot(s_od(rg), squeeze(oGC(1,2,rg))/gc_scale, '-o', 'markersize', 2,...
     s_od(rg), squeeze(oGC(2,1,rg))/gc_scale, '-o', 'markersize', 2);
set(gca, 'fontsize', 24);
xlabel('fitting order');
h=legend('GC Y->X', 'GC X->Y', 'location', 'northwest');
print('-depsc2', 'GC_od.eps');


% plot IC(od)

s1 = zeros(1, length(s_od));
for k=1:length(s_od)
%  od = s_od(k);
  s1(k) = log(det(oDe(:,:,k)));
end

figure(2);
plot(s_od(2:end), oAIC(2:end)/len, '-o', 'markersize', 2, s_od(2:end), s1(2:end), '-o', 'markersize', 2);
set(gca, 'fontsize', 24);
xlabel('fitting order');
h=legend('AIC/L', 'log\sigma^2');
print('-depsc2', 'AIC_od.eps');

if exist('pm','var')
  clear('X', 'ras');
  st_prefix = [pm.neuron_model '_'];
  if b_use_spike_train
    st_prefix = [st_prefix 'ST_'];
  end
  st_sc = strrep(mat2str([pm.scee, pm.scie, pm.scei, pm.scii]),' ',',');
  st_para = sprintf('%s_p=%d,%d_sc=%s_pr=%g_ps=%g_stv=%g_t=%.2e',...
      pm.net, pm.nE, pm.nI, st_sc(2:end-1), pm.pr, pm.ps, pm.stv, pm.t);
  if ~exist('file_suffix','var')
    file_suffix = '';
  end
  st_para = [st_prefix, st_para, file_suffix];
  if exist('path_prefix','var')
    path_prefix = [path_prefix, filesep];  % argly fix
  else
    path_prefix = './';
  end
  info_file_path = [path_prefix, 'GCinfo_', st_para, '.mat'];
  clear('st_sc', 'st_prefix', 'path_prefix');
  save('-v7', info_file_path);
  fprintf('Data saved to "%s"\n', info_file_path);
  % Later, use `show_analyse_GC_big_p.m' to load and analyse this file.
end
