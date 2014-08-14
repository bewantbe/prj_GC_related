%

netstr = 'net_2_2';
scee = 0.01;
pr = 1;
ps = 0.012;
simu_time = 1e5;
extst = 'new -q --RC-filter';
[X, ISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time+ext_T, stv, extst);

[~,s1]=sort(X(1,:));
[~,s2]=sort(X(2,:));
Y=zeros(size(X));
Y(1,s1) = 1:size(X,2);
Y(2,s2) = 1:size(X,2);

%figure(1);
%plot(X(:,1:100)')

%figure(2);
%plot(Y(:,1:100)')

pos_nGrangerT2(X,20)
pos_nGrangerT2(Y,20)

