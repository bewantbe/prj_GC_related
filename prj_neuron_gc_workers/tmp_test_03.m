%
tic;
s_od = 1:50;
%[oGC, oDe, R] = AnalyseSeries(X, s_od, 0);
[oGC, oDe, R] = AnalyseSeriesFast(X, s_od);

% p=100, m=50: 3278 v.s. 121.9
% p=100, m=20:  182 v.s.  30.4
% seems:   O(m^3.1) v.s. O(m^1.5)
% error: (GC or De) < 1e-14

toc;
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);

return

ooGC=oGC;
ooDe=oDe;
max(abs((oDe-ooDe)(:)))
max(abs((oGC-ooGC)(:)))

nn = getnetwork(netstr);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% print out data
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

%clear('X', 'ras');
%if strcmpi(mode_IF,'IF')
%    st_para0 = 'IF_';
%else
%    st_para0 = 'EIF_';
%end
%if mode_ST
%    st_para0 = [st_para0, 'ST_'];
%end
%st_para = sprintf('%s%s_sc=%1.3f_pr=%1.2f_ps=%1.3f_stv=%1.2f_t=%1.2e',...
%              st_para0, netstr, scee, pr, ps, stv, simu_time);
%save('-v7', ['result_',st_para,'.mat']);

rg = 34:99;
gc_scale = 1e-4;
figure(1);
%plot(s_od(rg), squeeze(oGC(1,2,rg))/gc_scale);
plot(s_od(rg), (squeeze(oGC(1,2,rg)) - s_od(rg)'/len)/gc_scale);
figure(2);
%plot(s_od(rg), squeeze(oGC(2,1,rg))/gc_scale)
plot(s_od(rg), (squeeze(oGC(2,1,rg)) - s_od(rg)'/len)/gc_scale)

