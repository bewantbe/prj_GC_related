% simple I&F GC calculation
pic_common_include;

disp('----------------------------------------------------------');
disp(' new run');
clear('stv','dt','extst');
clear('X', 'Xs', 'ras', 'scii');

tic;
mode_IF = 'IF';
mode_ST = 2;

netstr = 'net_100_01';
scee = 0.005;
pr = 0.24;
ps = 0.02;
extst = '--RC-filter -seed 154';

simu_time = 1e5;

pE = 100;
pI = 0;
if ~exist('pI') || pI==0
  sc = scee;
else
  sc = [scee, scee, scii, scii];
end
extst = [extst,' -n ',num2str(pE),' ',num2str(pI)];

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

if mode_ST
    [p, len] = size(X);
    Xs = zeros(p,len);
    for neuron_id=1:p
        Xs(neuron_id,:) = SpikeTrain(ras, len, neuron_id);
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
%disp('ISI:');
%disp(ISI);
disp([sprintf('mean ISI = %f', mean(ISI))]);
if ~exist('pI') || pI==0
    fprintf('%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
     netstr, scee, pr, ps, simu_time, stv, len);

    file_inf_st = sprintf('n=%d_%s_sc=%g_pr=%.2f_ps=%g_t=%.2e_stv=%g',...
                      p, netstr, scee, pr, ps, simu_time, stv);
else
    fprintf('%s, p:%d,%d, sc:%.3f,%.3f,%.3f,%.3f pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
     netstr, pE, pI, sc(1), sc(2), sc(3), sc(4), pr, ps, simu_time, stv, len);

    file_inf_st = sprintf('n=%d_%s_sc=[%g,%g,%g,%g]_pr=%.2f_ps=%g_t=%.2e_stv=%g',...
                      p, netstr, sc(1), sc(2), sc(3), sc(4), pr, ps, simu_time, stv);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% input data
[p,len] = size(X);
fprintf('read data: t = %6.3fs\n', toc());

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% analysis
s_od = 1:20;

lmix = 0.3;
%lmix=NaN;
if ~isnan(lmix)
  X = neu_volt_composer(X, [ras; 0,1e300]', stv);
  for k=1:size(X,1)
    mb = SpikeTrain(ras,size(X,2),k,[],[],1)>0;
    X(k,mb) = 0;
  end
  clear('mb');
  X = (1-abs(lmix))*X + lmix*Xs;
  %kmix = 1.0;
  %X = X + kmix*Xs;
end

tic;

[oGC, oDe, R] = AnalyseSeriesFast(X, s_od);
[aic_od, bic_od, zero_GC, oAIC, oBIC] = AnalyseSeries2(s_od, oGC, oDe, len);
%save('-v6','tmp_gc.mat','p','len','s_od','oGC','oDe','R');
fprintf('bo:%d  ao:%d\n',bic_od,aic_od);
fprintf('cal GC: t = %6.3fs\n', toc());

neu_net = getnetwork(netstr);
[edge_sort, edge_sort_id] = sort(neu_net(:));
figure(1);
plot(107*scee*edge_sort, zero_GC(edge_sort_id)/1e-4);
xlabel('S (in EPSP/mV)');
ylabel('F/1e-4');
pic_output_color(sprintf('gc_edge_sort_lmix=%.2f',lmix));

hist(pos_nGrangerT2(X,2)(eye(p)==0)/1e-4,100);
pic_output_color('h')

return

clear('X', 'Xs', 'ras', 'pic_data_save', 'pic_output', 'pic_output_color');
if strcmpi(mode_IF,'IF')
    st_para0 = 'IF_';
else
    st_para0 = 'EIF_';
end
if mode_ST
    st_para0 = [st_para0, 'ST_'];
end
if ~exist('pI') || pI == 0
    st_para = sprintf('%s%s_sc=%1.3f_pr=%1.2f_ps=%1.3f_stv=%1.2f_t=%1.2e',...
              st_para0, netstr, scee, pr, ps, stv, simu_time);
else
    st_para = sprintf('%s%s_p[%d,%d]_sc=[%1.3f,%1.3f,%1.3f,%1.3f]_pr=%1.2f_ps=%1.3f_stv=%1.2f_t=%1.2e',...
              st_para0, netstr, pE, pI, sc(1), sc(2), sc(3), sc(4), pr, ps, stv, simu_time);
end
save('-v7', ['result_',st_para,'.mat'], '*');

