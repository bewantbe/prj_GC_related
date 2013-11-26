%

p = 10;
len = 1e6;
X = rand(p, len);
rlen = len/100;
stv = 1.0;
T = sort(stv*len*rand(p,rlen), 2);
ras = [];
for k=1:p
  ras = [ras; [k*ones(rlen,1),T(k,:)']];
end
[~, rid] = sort(ras(:,2));
ras = ras(rid,:);

%ana_len = [-30,97];
disp('single test');
ana_len = 100*[-1,1];
%ana_len = 400;
tic
[v_sta1, t_rel1] = spikeTriggerAves(1, 1, ras, X, ana_len, stv);
t=toc
tic
[v_sta2, t_rel2] = spikeTriggerAve(1, 1, ras, X, ana_len, stv);
t=toc

norm(v_sta1-v_sta2)
norm(t_rel1-t_rel2)

disp('\nmultiple test');
s = 1:2:p;
tic
[v_sta1, t_rel1] = spikeTriggerAves(1, s, ras, X, ana_len, stv);
t=toc
tic
if length(ana_len)==1
  v_sta2 = zeros(length(s), ana_len);
else
  v_sta2 = zeros(length(s), ana_len(2)-ana_len(1)+1);
end
for k=1:length(s)
  [v_sta2(k,:), t_rel2] = spikeTriggerAve(1, s(k), ras, X, ana_len, stv);
end
t=toc

norm((v_sta1-v_sta2)(:))
