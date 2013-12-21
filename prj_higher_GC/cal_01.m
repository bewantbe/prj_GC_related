%
clear('stv','dt','extst');
extst = '';
stv = 1/2;

for cs=1:1

mode_IF = 'IF';
mode_ST = 0;
netstr = 'net_2_2';
scee = 0.01;

%pr = 1.0;
%ps = 0.012;
switch cs
  case 1
    pr = 0.24;
    ps = 0.02;
  case 2
    pr = 0.38;
    ps = 0.02;
  case 3
    pr = 0.5;
    ps = 0.02;
  case 4
    pr = 1.7;
    ps = 0.02;
  case 5
    pr = 0.45;
    ps = 0.012;
  case 6
    pr = 0.6;
    ps = 0.012;
  case 7
    pr = 1.0;
    ps = 0.012;
  case 8
    pr = 2.0;
    ps = 0.012;
  case 9
    pr = 1.2;
    ps = 0.005;
  case 10
    pr = 1.5;
    ps = 0.005;
  case 11
    pr = 2.5;
    ps = 0.005;
  case 12
    pr = 5.0;
    ps = 0.005;
  otherwise
    error('haha');
end
simu_time = 1e6;
extst = '--RC-filter -q';

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

%X = neu_volt_composer(Xv, [ras; 0,1e300]', stv, [-1 0]);
X = [Xv(:,1),diff(Xv,1,2)];
for k=1:size(X,1)
  mb = SpikeTrain(ras,size(X,2),k,[],[],1)>0;
  X(k,mb) = 0;
  X(k,shift(mb,1)) = 0;
  X(k,shift(mb,2)) = 0;
end
[p, len] = size(Xs);

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
%bv = basic_analyse(Xv, s_od);
%fprintf('Volt:\t%s\n', str_b_brief(bv));
%fflush(stdout);
%bs = basic_analyse(Xs, s_od);
%fprintf('ST:\t%s\n', str_b_brief(bs));
%fflush(stdout);

for k=1:p
  %X(k,shift(Xs(k,:)>0,-2)) = 0;
  %X(k,shift(Xs(k,:)>0,-1)) = 0;
  %X(k,shift(Xs(k,:)>0,1)) = 0;
  %X(k,shift(Xs(k,:)>0,2)) = 0;
  %X(k,shift(Xs(k,:)>0,3)) = 0;
end

Xcom = X;
s_kmix_set1 = [-9.0 -5.0 -2.5 -1.5 -1.0 -0.7 -0.5 -0.3 -0.2 -0.1 0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 1.0 1.4 2.0 5.0 9.0];
s_kmix_set2 = [0.3 0.4 0.5 0.6 0.8 1.0 1.4 2.0 5.0];
s_kmix_short = [0.3 0.5 0.7 1.0];
s_kmix_0 = [1.0];

for kmix = s_kmix_set1
  X = Xcom + kmix*Xs;
  b = basic_analyse(X, s_od);
  fprintf('%5.2f\t%s\n', kmix,str_b_brief(b)); 
  fflush(stdout);
end

%bg = 1e5;
%rg0 = 1:100;
%rg = bg+rg0;
%figure(1);
%%hd=plot(rg0, Xv(:,rg), '-x', rg0, X(:, rg), '-o', rg0, Xd(:,rg), '-+');
%hd=plot(rg0, Xv(:,rg), '-x', rg0, X(:, rg), '-o');
%set(hd,'markersize',3);

%figure(2);
%plainlize = @(A) [squeeze(b.oGC(2,1,:))'; squeeze(b.oGC(1,2,:))']; 
%plot(b.s_od, [plainlize(b.oGC); b.s_od/len]);

end
