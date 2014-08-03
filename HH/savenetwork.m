% Save the adjacency matrix `A' in path `pathdir' with a hashed file name:
%   matpath = savenetwork(A, pathdir);
% To read the matrix from the file:
%   A = load('-ascii', matpath);

function [matpath, matname] = savenetwork(A, pathdir)

% sane test of the matrix A
if ~exist('A','var') || isempty(A) || (~isnumeric(A) && ~islogical(A))
  error('Input a numeric matrix please!');
end
if size(A,1) ~= size(A,2) || ndims(A) ~= 2
  error('Not a square matrix!');
end
A = double(A);  % int32,logical to double, so get consistent hash result

e = filesep;
if ~exist('pathdir','var')
  pathdir = '';    % save to default dir (usually working dir)
end
% Always consider `pathdir' as dir name
if ~isempty(pathdir) && pathdir(end) ~= '/' && pathdir(end) ~= e
  pathdir = [pathdir e];
end

% Give this matrix a name
p = length(A);
matname = ['net_', num2str(p), '_0X', BKDRHash(mat2str(A))];
matpath = [pathdir, matname, '.txt'];

% If there is a file with the same name
if ~isempty(dir(matpath))
  B = load('-ascii', matpath);
  if norm(A(:)-B(:))>0
    % TODO: solve it by re-hash?
    error('hash collision! Currently need to solve by hand...');
  end
  return
end

% Save the matrix to the file
if all(floor(A(:)) == A(:))
  % all integers, so let's save it in a cleaner way
  A = int2str(int32(A));
  fd = fopen(matpath, 'w');
  if fd == -1
    error('Unable to open output file `%s''', matpath);
  end
  for jj=1:p
    fprintf(fd, '%s\n', A(jj,:));
  end
  fclose(fd);
else
  % save the matrix in full precision ascii format
  save('-ascii', '-double', matpath, 'A');
end
