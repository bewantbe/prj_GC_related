%
clear('stv','dt','extst');
extst = '';
stv = 1/2;

mode_IF = 'IF';
mode_ST = 0;
netstr = 'net_2_2';
scee = 0.01;
pr = 1.0;
ps = 0.012;
%pr = 0.24;
%ps = 0.02;
%pr = 0.5;
%ps = 0.02;
%pr = 1.7;
%ps = 0.02;
simu_time = 1e6;
extst = '--RC-filter -seed 341432443';

if strcmpi(mode_IF,'ExpIF')
    extst = ['ExpIF ',extst];
end
if exist('dt','var')
    extst = [extst, sprintf(' -dt %.16e',dt)];
end

[Xv, ISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time, stv, extst);

Xs = zeros(size(Xv));
for neuron_id=1:size(Xs,1)
    Xs(neuron_id,:) = SpikeTrain(ras, size(Xv,2), neuron_id, [], [], 0);
end

X = neu_volt_composer(Xv, [ras; 0,1e300]');
for k=1:size(X,1)
  X(k,SpikeTrain(ras,size(X,2),k,[],[],1)>0) = 0;
end

[p, len] = size(Xv);

if strcmpi(mode_IF,'IF')
    s_od = 1:99;  % for IF
else
    s_od = 1:499;  % for EIF
end

fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
 netstr, scee, pr, ps, simu_time, stv, len);
disp(['ISI: ', num2str(ISI)]);
str_b_brief = @(b) sprintf('%5.2f (%5.2f)\t%5.2f (%5.2f)',...
  b.zero_GC(2,1)/1e-4, b.oGC(2,1,b.bic_od)/(b.bic_od/b.len),...
  b.zero_GC(1,2)/1e-4, b.oGC(1,2,b.bic_od)/(b.bic_od/b.len)); 
bv = basic_analyse(Xv, s_od);
fprintf('Volt:\t%s\n', str_b_brief(bv));
fflush(stdout);
bs = basic_analyse(Xs, s_od);
fprintf('ST:\t%s\n', str_b_brief(bs));
fflush(stdout);

for k=1:p
  %X(k,shift(Xs(k,:)>0,-2)) = 0;
  %X(k,shift(Xs(k,:)>0,-1)) = 0;
  %X(k,shift(Xs(k,:)>0,2)) = 0;
  %X(k,shift(Xs(k,:)>0,3)) = 0;
end
%X(Xs>0) = -0.5*Xs(Xs>0);

%for pr=1, ps=0.012
%X(Xs>0) = -0.3*Xs(Xs>0);  % GC1=8.67, GC0=0.09(1.18)
%X(Xs>0) = 0.2*Xs(Xs>0);   % GC1=16.73, GC0=0.38(9.22)

%for pr=1, ps=0.012
%X(Xs>0) = -0.5*Xs(Xs>0);

kmix = 1.0;
Xcom = X;
for kmix=[-9.0 -5.0 -2.5 -1.5 -1.0 -0.7 -0.5 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 1.0 1.4 2.0 5.0 9.0]
  X = Xcom + kmix*Xs;

  b = basic_analyse(X, s_od);
  fprintf('%5.2f\t%s\n', kmix,str_b_brief(b)); 
  fflush(stdout);
end

%bg = 1e5;
%rg0 = 1:100;
%rg = bg+rg0;
%figure(1);
%hd=plot(rg0, Xv(:,rg), '-o', rg0, X(:, rg), '-o');
%set(hd,'markersize',3);

%figure(2);
%plainlize = @(A) [squeeze(b.oGC(2,1,:))'; squeeze(b.oGC(1,2,:))']; 
%plot(b.s_od, [plainlize(b.oGC); b.s_od/len]);

