% test the network
addpath('~/matcode/libs/matlab_networks_routines');
tic;

%adj = load('net_100_10.txt');
%n = size(adj,1);
rand('state',5);            % set initial state

n = 100;
adj = zeros(n);
if ~exist('n_neighbour','var')
  n_neighbour = 5;
end
for k=1:n_neighbour
  adj = adj + diag(ones(1,n-k),k);
  adj = adj + diag(ones(1,k),n-k);
  adj = adj + diag(ones(1,n-k),-k);
  adj = adj + diag(ones(1,k),k-n);
end

id1  = adj==1;
id1f = find(id1);
id0  = adj==0 & eye(n)==0;
id0f = find(id0);

n_exp = 100;  % 2.2 sec per exp, when n=100
s_C1 = zeros(1,n_exp);
s_C2 = zeros(1,n_exp);
s_L  = zeros(1,n_exp);
s_adj = cell(1,n_exp);
for k=1:n_exp
  s_adj{k} = adj;
  [C1,C2] = clust_coeff(adj);
  ddist=distance_distribution(adj);
  L = sum(ddist .* (1:n-1))/sum(ddist);
  s_C1(k) = C1;
  s_C2(k) = C2;
  s_L(k)  = L;
  adj(id1f(ceil(sum(id1)*rand(1)))) = 0;
  adj(id0f(ceil(sum(id0)*rand(1)))) = 1;
end

k_id = 1:n_exp;

st_inf = sprintf('n=%d_ndiag=%d_nexp=%d', n, n_neighbour, n_exp);
save([st_inf,'_adj.mat'],'s_adj');
picsave = @(st) print('-depsc2', sprintf('%s_%s.eps', st_inf, st));

figure(1);
plot(k_id, s_C1, '-o', k_id, s_C2, '-o');
legend('C1', 'C2');
picsave('C');

figure(2);
plot(k_id, s_L, '-o');
picsave('L');

toc;
