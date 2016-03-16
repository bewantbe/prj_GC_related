function ras2SpikeTrainFile(ras, p, len, stv, fname)
  if any(ras(:,1)>p)
    error('!! any(ras(:,1)>p)');
  end
  max_mem_byte = 256*2^20;
%  max_mem_byte = 8*2*4;
  mlen = floor(max_mem_byte/8/p);
  if mlen == 0
    warning('running crazy thing...');
    mlen = 10;
  end
  cnt = 0;
  ras_pointer_bg = 1;
  ras_pointer_ed = 1;
  fid = fopen(fname, 'w');
  for k = 1:ceil(len/mlen)
    if k == 1
      X = zeros(p, rem(len-1, mlen)+1);
    else
      X = zeros(p, mlen);
    end
    t_end = (cnt + size(X,2))*stv;
    ras_pointer_ed = ras_pointer_bg + find(ras(ras_pointer_bg:end,2)>=t_end, 1, 'first')-1;
%    fprintf('t = [%f ~ %f), id = %f ~ %f - 1\n', cnt*stv, t_end, ras_pointer_bg, ras_pointer_ed);
    % write spike train in [ras_pointer_bg, ras_pointer_ed)
    if isempty(ras_pointer_ed)
      ras_pointer_ed = size(ras,1)+1;
    end
%    ras_in_range = ras(ras_pointer_bg:ras_pointer_ed-1, :)
    X( ras(ras_pointer_bg:ras_pointer_ed-1, 1)...
      + p*(floor(ras(ras_pointer_bg:ras_pointer_ed-1, 2)/stv-cnt)) ) = 1;
    % TODO: to overcome repeated values
    % unv = unique(v);
    % X(unv) = histc(v,unv);
%    X
    fwrite(fid, X, 'double');
    ras_pointer_bg = ras_pointer_ed;
    cnt = cnt + size(X,2);
  end
  fclose(fid);
  if (cnt~=len)
    error('********************  damn! Bug  *********************');
  end
end

%{
  % test code
  t = 100000;
  p = 100;
  len_ras = ceil(35*p*t/1000);
  ras = [randi(p, len_ras, 1) t*sort(rand(len_ras,1))];
  stv = 0.5;
  fname = 'test_ST.dat';
  ras2SpikeTrainFile(ras, p, t/stv, stv, fname);

  fid = fopen(fname, 'r');
  X = fread(fid, [p, Inf], 'double');
  fclose(fid);

%  ras0 = ras;
%  ras0(:,2) = ras0(:,2) + stv/2;  % SpikeTrains use round() for timing
%  ST = SpikeTrains(ras0, p, t/stv, stv);

  ST = SpikeTrainsFast(ras, p, t/stv, stv);

%  sum(X(:)~=ST(:))
  sum(sum(X(:, 3:end-2)~=ST(:, 3:end-2)))
%}
