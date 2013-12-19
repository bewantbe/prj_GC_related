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
    Xs(neuron_id,:) = SpikeTrain(ras, size(Xv,2), neuron_id, [], [], 1);
end

X = neu_volt_composer(Xv, [ras; 0,1e300]');

[p, len] = size(Xv);

if strcmpi(mode_IF,'IF')
    s_od = 1:99;  % for IF
else
    s_od = 1:499;  % for EIF
end

%return
%bv = basic_analyse(Xv, s_od);
%disp(' ');  fflush(stdout);
%bs = basic_analyse(Xs, s_od);

for k=1:p
  X(k,shift(Xs(k,:)>0,-2)) = 0;
  X(k,shift(Xs(k,:)>0,-1)) = 0;
  X(k,shift(Xs(k,:)>0,1)) = 0;
  X(k,shift(Xs(k,:)>0,2)) = 0;
  X(k,shift(Xs(k,:)>0,3)) = 0;
end
X(Xs>0) = +0.5*Xs(Xs>0);
b = basic_analyse(X, s_od);

bg = 1e5;
rg0 = 1:100;
rg = bg+rg0;
figure(1);
%plot(rg0, Xv(:,rg), rg0, Xs(:, rg));
plot(rg0, Xv(:,rg), rg0, X(:, rg));

