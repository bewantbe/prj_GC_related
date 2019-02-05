% 

function [p_correct, n_over, n_lack, n_conn] = gc_net_quality(GC, gc_zero_cut, neu_network, p)

  if ~exist('p', 'var')
    p = length(neu_network);
  end

  neu_network_guess = GC >= gc_zero_cut;
  adj_cmp = neu_network_guess - neu_network;

  n_over = sum((adj_cmp(:)==1));
  n_lack = sum((adj_cmp(:)==-1));
  n_conn = sum(neu_network(:));
  p_correct = 1-(n_over+n_lack)/(p*(p-1));
  
  disp(['over guess: ', num2str(n_over)]);
  disp(['lack guess: ', num2str(n_lack)]);
  fprintf('connection: %d / %d = %.1f%%\n', n_conn, p*(p-1),...
          100*n_conn/(p*(p-1)));
  fprintf('Overall correctness: %.1f %%\n', 100*p_correct);

