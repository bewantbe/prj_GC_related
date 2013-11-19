% test the network
tic;

load('ty_yx_n=100_ndiag=5_nexp=20_adj.mat');
n = 100;
n_neighbour = 5;
n_exp = length(s_adj);

s_C = zeros(1,length(s_adj));
s_L = zeros(1,length(s_adj));
for k=1:length(s_adj)
  adj = s_adj{k};
  s_C(k) = clustering_coef_BDN(adj);
  s_L(k) = avePathLength(adj);
  edges = sum(adj(:))
  fflush(stdout);
end

k_id = 1:length(s_adj);

st_inf = sprintf('ty_yx_n=%d_ndiag=%d_nexp=%d', n, n_neighbour, n_exp);
%save([st_inf,'_adj.mat'],'s_adj');
picsave = @(st) print('-depsc2', sprintf('%s_%s_printver.eps', st_inf, st));

figure(1);  set(gca,'fontsize', 20);
plot(k_id, s_C, '-o');
%legend('C');
picsave('C');

figure(2);  set(gca,'fontsize', 20);
plot(k_id, s_L, '-o');
picsave('L');

figure(3);  set(gca,'fontsize', 20);
adj2adjmatrix(adj);
picsave('adjmat');

toc;
