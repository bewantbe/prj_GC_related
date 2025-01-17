% simple I&F GC calculation

disp('----------------------------------------------------------');
disp(' new run');
clear('stv','dt','extst');

tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate data (IF model)
% 'net_2_2'    scee=0.01;  pr=0.24, 0.38, 0.5, 1.7; ps=0.02; simu_time=1e7, 5e7;
% 'net_3_06'   scee=0.01;  pr=0.5, 1.7; ps=0.02; simu_time=1e7;
% 'net_3_09'   scee=0.01;  pr=0.5; ps=0.02;  simu_time=1e7;
% 'net_5_1'    scee=0.01;  pr=1.0; ps=0.007; simu_time=5e7;
% 'net_100_01' scee=0.005; pr=6.0; ps=0.001; simu_time=1e6; '-dt 0.0078125 --RC-filter -seed 2633014931'
% 'net_100_01' scee=0.01, 0.005; pr=0.24; ps=0.02;  simu_time=1e6; '--RC-filter -seed 1367598138'
% 'net_2_2'    scee=0.01;  pr=1.0; ps=0.001; simu_time=1e7; '-dt 0.0078125 --RC-filter -seed 1315717123 --pr-mul 8 7 --ps-mul 1 1'

mode_IF = 'IF';
mode_ST = 0;
netstr = 'net_100_20';
%netstr = 'net_100_21';
scee = 0.004;
pr = 1.0;
ps = 0.012;
simu_time = 1e6;
extst = '--RC-filter -seed 124';

pE = 80;
pI = 20;
sc = [scee, scee, 0.008, 0.008];
extst = [extst,' -n ',num2str(pE),' ',num2str(pI)];

%mode_IF = 'IF';
%mode_ST = 0;
%netstr = 'net_2_2';
%scee = 0.01;
%pr = 0.5;
%ps = 0.02;
%simu_time = 1e5;
%extst = '--RC-filter';

%mode_IF = 'IF';
%mode_ST = 0;
%netstr = 'net_12_net2_2';
%scee = 0.01;
%pr = 2.0;
%ps = 0.01;
%simu_time = 1e6;
%pr_mul_first = 0.01;
%extst = ['--RC-filter --pr-mul ', num2str([pr_mul_first pr_mul_first],'%.16e ')];

%mode_IF = 'IF';
%mode_ST = 0;
%netstr = 'net_2_1';
%scee = 0.01;
%pr = 1.0;
%ps = 0.01;
%simu_time = 1e7;
%extst = 'co --RC-filter --pr-mul 0.3 0.3 0.7';
%extst = 'new --RC-filter -seed 2633014931';
%extst = '--RC-filter -seed 2633014931';
%extst = 'ExpIF -dt 0.004 --RC-filter';

if ~exist('extst','var')
    extst = '';
end
if strcmpi(mode_IF,'ExpIF')
    extst = ['ExpIF ',extst];
end
if exist('dt','var')
    extst = [extst, sprintf(' -dt %.16e',dt)];
end
if ~exist('stv','var')
    stv = 1/2;
end
[X, ISI, ras] = gendata_neu(netstr, sc, pr, ps, simu_time, stv, extst);

%% resample
%X = X(:,1:2e6);
%simu_time = 1e6;
X = X(:,1:2:end);
stv = stv*2;

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
disp([sprintf('mean ISI = %f', mean(ISI))]);
if ~exist('pI')
    fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
     netstr, scee, pr, ps, simu_time, stv, len);

    file_inf_st = sprintf('n=%d_%s_sc=%g_pr=%.2f_ps=%g_t=%.2e_stv=%g',...
                      p, netstr, scee, pr, ps, simu_time, stv);
else
    fprintf('net:%s, p:%d,%d, sc:%.3f,%.3f,%.3f,%.3f pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
     netstr, pE, pI, sc(1), sc(2), sc(3), sc(4), pr, ps, simu_time, stv, len);

    file_inf_st = sprintf('n=%d_%s_sc=[%g,%g,%g,%g]_pr=%.2f_ps=%g_t=%.2e_stv=%g',...
                      p, netstr, sc(1), sc(2), sc(3), sc(4), pr, ps, simu_time, stv);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input data
[p,len] = size(X);
fprintf('read data: t = %6.3fs\n', toc());

tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% analysis
if strcmpi(mode_IF,'IF')
    s_od = 1:99;  % for IF
    s_od = 1:20;
else
    s_od = 1:499;  % for EIF
end
[oGC, oDe, R] = AnalyseSeries(X, s_od, 0);
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
%save('-v6','tmp_gc.mat','p','len','s_od','oGC','oDe','R');
fprintf('cal GC: t = %6.3fs\n', toc());

%{
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
  disp('GC(od=zero)*1e4:');
  disp(1e4*zero_GC);
  disp('non-zero test (at bic_od):');
  disp(gc_prob_nonzero(oGC(:,:,bic_od),bic_od,len));
  disp('confidence intervals (at bic_od):');
  [gc_lower, gc_upper] = gc_prob_intv(oGC(:,:,bic_od), bic_od, len);
  disp('lower*1e4:');
  disp(gc_lower*1e4);
  disp('upper*1e4:');
  disp(gc_upper*1e4);
format 'short'
disp('var ratio (at bic_od): var(x)/var(\epsilon), var(y)/var(\eta)');   % for 2-var only
disp([num2str(R(1,1)/oDe(1,1,bic_od)), ' ', num2str(R(2,2)/oDe(2,2,bic_od))]);
%}

clear('X', 'ras');
if strcmpi(mode_IF,'IF')
    st_para0 = 'IF_';
else
    st_para0 = 'EIF_';
end
if mode_ST
    st_para0 = [st_para0, 'ST_'];
end
if ~exist('pI')
    st_para = sprintf('%s%s_sc=%1.3f_pr=%1.2f_ps=%1.3f_stv=%1.2f_t=%1.2e',...
              st_para0, netstr, scee, pr, ps, stv, simu_time);
else
    st_para = sprintf('%s%s_p[%d,%d]_sc=[%1.3f,%1.3f,%1.3f,%1.3f]_pr=%1.2f_ps=%1.3f_stv=%1.2f_t=%1.2e',...
              st_para0, netstr, pE, pI, sc(1), sc(2), sc(3), sc(4), pr, ps, stv, simu_time);
end
save('-v7', ['result_',st_para,'.mat'], '*');

