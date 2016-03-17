function MatShow(A, err)
  if ~exist('err','var')
    err = 1e-3;
  end
  imagesc(A); colorbar; caxis([-1 1]*err*max(abs(A(:))));
end
