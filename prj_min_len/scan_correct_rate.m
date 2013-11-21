% parallel scan framework

if ~b_have_head
  netstr = 'net_2_2';
  scee   = 0.01;
  pr     = 1;
  ps     = 0.012;
  simu_time = 1e5;
  stv = 0.5;
  extst = ' --RC-filter -q';
  mode_ST = 0;
  s_od = 1:50;
  % job index set
  s_jobs = 1:10000;
end

s_data = cell(size(s_jobs));

data_file_name = sprintf('scan_correct_%s_sc=%.3f_pr=%.2f_ps=%.3f_T=%.1e_stv=%.2f_j%d.mat',...
                            netstr, scee, pr, ps, simu_time, stv, numel(s_jobs));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
t0 = tic();
tocs = @(st) fprintf('%s: t = %6.3fs\n', st, toc());

ext_T = 1e4;  % avoid head effect

% prepare parallel
s_b_finished = false(size(s_jobs));
s_b_launched = false(size(s_jobs));
[~, ncpu] = system('nproc');         % get number of cpus
ncpu = max([str2num(ncpu), 1]);      % or leave one for other job?
id_jobs_head = 1;                    % the first unfinished job
num_launched = 0;                    % number of paralled jobs that launched

while ~isempty(id_jobs_head)
  for id_jobs=id_jobs_head:numel(s_jobs)
    if s_b_finished(id_jobs)
      continue
    end

    % calculate input parameters here
    data_dir_prefix = sprintf('data/d%04d_', id_jobs);

    if s_b_launched(id_jobs)
      [X, ISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time+ext_T, stv, ['read ' extst], data_dir_prefix);
      if isempty(X)   % data is not ready
        pause(0.1);   % save CPU time
        continue
      end
      X(:, 1:round(ext_T/stv)) = [];  % cut head
      if ~isempty(ras)
        ras(ras(:,2)<=ext_T, :) = [];
        ras(:,2) = ras(:,2) - ext_T;
      end
      if mode_ST                      % convert spike train if necessary
        for neuron_id = 1:p
          st = SpikeTrain(ras, len, neuron_id, 1, stv);
          X(neuron_id,:) = st;
        end
      end
    else
      pause(0.1);     % save CPU time, and do not push too fast
      % enough available cpu resources?
      if num_launched >= ncpu 
        break;        % restart the loop, wait for the launched ones
      end
      gendata_neu(netstr, scee, pr, ps, simu_time+ext_T, stv, ['new ', extst, ' &'], data_dir_prefix);
      s_b_launched(id_jobs) = true;
      num_launched = num_launched + 1;
      fprintf('id_jobs =%4d launched.\n', id_jobs);  flushstdout();
      continue
    end

    % process data
    [oGC, oDe, R] = AnalyseSeriesFast(X, s_od);
    da.oGC = oGC;  da.oDe = oDe;  da.R   = R;
    da.netstr=netstr; da.scee=scee; da.pr=pr; da.ps=ps; da.simu_time=simu_time; da.stv=stv; da.extst=extst;
    da.ISI=ISI;
    s_data{id_jobs} = da;

    s_b_finished(id_jobs) = true;
    if id_jobs == id_jobs_head
      id_jobs_head = id_jobs_head + find(~s_b_finished(id_jobs:end), 1) - 1;
    end
    % delete temporarily file, to save disk space
    gendata_neu(netstr, scee, pr, ps, simu_time+ext_T, stv, ['rm ' extst], data_dir_prefix);
    num_launched = num_launched - 1;
    fprintf('id_jobs =%4d finished.\n', id_jobs);  flushstdout();
  end  % for id_jobs
end  % while parallel

save('-v7', data_file_name, 's_data', 's_od', 's_jobs','ext_T',...
'netstr','scee','pr','ps','simu_time','stv','extst','mode_ST');

fprintf('Elapsed time is %6.3f\n', (double(tic()) - double(t0))*1e-6 );
