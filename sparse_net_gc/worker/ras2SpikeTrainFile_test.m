%

  t = 2e6;
  p = 100;
  len_ras = ceil(35*p*t/1000);
  ras = [randi(p, len_ras, 1) t*sort(rand(len_ras,1))];
  stv = 0.5;
  fname = 'test_ST.dat';
  tic;
  ras2SpikeTrainFile(ras, p, t/stv, stv, fname);
  toc

  tic;
  fid = fopen(fname, 'r');
  X = fread(fid, [p, Inf], 'double');
  fclose(fid);
  toc;

%  ras0 = ras;
%  ras0(:,2) = ras0(:,2) + stv/2;  % SpikeTrains use round() for timing
%  tic
%  ST = SpikeTrains(ras0, p, t/stv, stv);
%  toc
%  sum(sum(X(:, 3:end-2)~=ST(:, 3:end-2)))

  tic
  ST = SpikeTrainsFast(ras, p, t/stv, stv);
  toc
  fprintf('Number of errors:\n');
  sum(X(:)~=ST(:))

  tic
  STa = SpikeTrainsFast(ras, p, t/stv, stv, 1);
  toc
  fprintf('Number of errors:\n');
  sum(X(:)~=(STa(:)>0))

