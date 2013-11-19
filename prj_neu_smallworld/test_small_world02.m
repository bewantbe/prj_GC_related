% test the network
tic;
%rand('state',5);            % set initial state

n = 100;
adj = zeros(n);
if ~exist('n_neighbour','var')
  n_neighbour = 5;
end

% generate the graph
dg = @(k) diag(ones(1,n-abs(k)),k) + diag(ones(1,abs(k)),-sign(k)*(n-abs(k)));
adj = dg(2) + dg(-2) + dg(1) + dg(-1);
%adj = dg(2) + dg(-2) + dg(-1);

n_exp = 100;  % 2.2 sec per exp, when n=100
s_C = zeros(1,n_exp);
s_L = zeros(1,n_exp);
s_adj = cell(1,n_exp);
for k=1:n_exp
  s_adj{k} = adj;
  C = clustering_coef_BDN(adj);
  %ddist=distance_distribution(adj);
  %L = sum(ddist .* (1:n-1))/sum(ddist);
  L = avePathLength(adj);
  s_C(k) = C;
  s_L(k)  = L;
  id1f = find(adj==1);
  id0f = find(adj==0);
  adj(id1f(ceil(length(id1f)*rand(1)))) = 0;
  adj(id0f(ceil(length(id0f)*rand(1)))) = 1;
end

k_id = 1:n_exp;

st_inf = sprintf('ty_yx_n=%d_ndiag=%d_nexp=%d', n, n_neighbour, n_exp);
save([st_inf,'_adj.mat'],'s_adj');
picsave = @(st) print('-depsc2', sprintf('%s_%s.eps', st_inf, st));

figure(1);
plot(k_id, s_C, '-o');
legend('C');
picsave('C');

figure(2);
plot(k_id, s_L, '-o');
picsave('L');

toc;
