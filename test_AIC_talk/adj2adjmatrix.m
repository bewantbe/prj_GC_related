%

function adj2adjmatrix(A, basename)
  n = size(A,1);
  if (n ~= size(A,2)) || (ndims(A)~=2)
    error('Only accept square matrix');
  end
  A_e = [[flipud(A); zeros(1,n)], zeros(n+1,1)];

  % for binary graph, use black and white
  if sum(sum(A_e~=0 & A_e~=1)) == 0
    colormap(flipud(colormap('gray')));
  end
  pcolor(A_e);
  axis('square','off');
  % for large graph, don't show edges
  if (n>9)
    shading('flat');
  else
    shading('faceted');
    %set(gca,'linewidth', 0.5);  % no use in octave
  end
  gap = 0.5;
  %line([1,n+1,n+1,1-gap,1-gap],[1,1,n+1+gap,n+1+gap,1],[1,1,1,1,1]);
  line([1-gap,n+1+gap,n+1+gap,1-gap,1-gap],[1-gap,1-gap,n+1+gap,n+1+gap,1-gap],[1,1,1,1,1]);
 
