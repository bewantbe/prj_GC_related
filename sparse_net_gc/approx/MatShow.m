function MatShow(A, err)
  if ~exist('err','var')
    err = 1e-3;
  end
    imagesc(A); colorbar;
  if err>0
    caxis([-1 1]*err*max(abs(A(:))));
  else
    caxis([-1 1]*(-err));
  end
end
