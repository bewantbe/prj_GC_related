% simple I&F GC calculation

disp('----------------------------------------------------------');
disp(' new run');
clear('stv','dt','extst');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate data

mode_IF = 'IF';
mode_ST = 0;

netstr = 'net_2_2';
scee = 0.05;
pr = 1.6;
ps = 0.04;
simu_time = 1e5;
stv = 0.5;
extst = 'new --RC-filter';

ext_T = 1e4;

pm.net  = netstr;
pm.ps   = ps;
pm.pr   = pr;
pm.scee = scee;
pm.t    = simu_time + ext_T;
pm.dt   = 1/32;
pm.stv  = stv;

%[X, ISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time+ext_T, stv, extst);
[X, ISI, ras] = gen_HH(pm);
X = X(:, round(ext_T/stv)+1:end);
if ~isempty(ras)
  ras(ras(:,2)<=ext_T, :) = [];
end
for id_p = 1:size(X,1)
  ISI(id_p) = simu_time/(sum(ras(:,1)==id_p,1));
end

%fprintf('common   input rate: %.2f\n', sum(1./ISI(3:end)));
%fprintf('external input rate: %.2f\n', pr_mul_first*pr);

% only analyse first two neuron
%X = X(1:2,:);
%ISI = ISI(1:2);
%ras(ras(:,1)>2, :) = [];

if mode_ST
    [p, len] = size(X);
    clear('X');
    X = zeros(p,len);
    for neuron_id=1:p
        X(neuron_id,:) = SpikeTrain(ras, len, neuron_id);
    end
end

%figure(1);
%bg  = 1e4;
%len = 100;
%rg  = bg:bg+len-1;
%plot(rg*stv, X(:,rg));
%xlabel('time /ms');
%ylabel('volt');
%legend('x','y');

[p, len] = size(X);
disp('ISI:');
disp(ISI);
fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
 netstr, scee, pr, ps, simu_time, stv, len);

file_inf_st = sprintf('n=%d_%s_sc=%g_pr=%.2f_ps=%g_t=%.2e_stv=%g',...
                      p, netstr, scee, pr, ps, simu_time, stv);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input data
[p,len] = size(X);

tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% analysis
if strcmpi(mode_IF,'IF')
    s_od = 1:99;  % for IF
else
    s_od = 1:499;  % for EIF
end
[oGC, oDe, R] = AnalyseSeries(X, s_od, 0);
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
%save('-v6','tmp_gc.mat','p','len','s_od','oGC','oDe','R');
toc

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

