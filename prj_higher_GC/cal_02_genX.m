
function [Xcom, Xs, Xv] = cal_02_genX(cid, b_verbose)
extst = '';
stv = 1/2;

mode_IF = 'IF';
mode_ST = 0;
netstr = 'net_2_2';
scee = 0.01;

%pr = 1.0;
%ps = 0.012;
s_prps = [
0.24,0.02
0.38,0.02
0.50,0.02
1.70,0.02
0.45,0.012
0.6,0.012
1.0,0.012
2.0,0.012
1.2,0.005
1.5,0.005
2.5,0.005
5.0,0.005
];
pr = s_prps(cid,1);
ps = s_prps(cid,2);

simu_time = 1e5;
extst = 'new --RC-filter -q';

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

Xcom = neu_volt_composer(Xv, [ras; 0,1e300]', stv);
for k=1:size(Xcom,1)
  Xcom(k,SpikeTrain(ras,size(Xcom,2),k,[],[],1)>0) = 0;
end

[p, len] = size(Xs);
for k=1:p
  %Xcom(k,shift(Xs(k,:)>0,-2)) = 0;
  %Xcom(k,shift(Xs(k,:)>0,-1)) = 0;
  %Xcom(k,shift(Xs(k,:)>0,2)) = 0;
  %Xcom(k,shift(Xs(k,:)>0,3)) = 0;
end

if exist('b_verbose','var') && ~isempty(b_verbose)
  fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
   netstr, scee, pr, ps, simu_time, stv, len);
  disp(['ISI: ', num2str(ISI)]);
end

