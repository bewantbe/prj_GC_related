% Parallel scan framework.
% Input           Type         What for
% s_jobs          cell array   Input data for each job
% in_const_data   (any)        Extra input data for each job
% func_name       string       The function for each job
% data_file_name  string       For saving results
% prefix_tmpdata  string       Prefix for input/output file.

if exist('OCTAVE_VERSION','builtin')
  exec_name = 'octave -qf --no-window-system --eval ';
else
  exec_name = 'matlab -nodisplay -nojvm -r ';
end

if ~exist('ncpu','var')
  [~, ncpu] = system('nproc');         % get number of cpus
  ncpu = max([str2num(ncpu), 1]);      % or leave one for other job?
end

if ~exist('fflush','builtin')
  fflush = @(x) x;
  stdout = 1;
end

if ~exist('in_const_data', 'var')
  in_const_data = [];  % no extra input data
end

% will save all results to this array
s_data = cell(size(s_jobs));

% prepare parallel
s_b_finished = false(size(s_jobs));
s_b_launched = false(size(s_jobs));
id_jobs_head = 1;                    % the first unfinished job
num_working  = 0;                    % number of paralled jobs that working

while ~isempty(id_jobs_head)
  for id_job=id_jobs_head:numel(s_jobs)
    if s_b_finished(id_job)
      continue
    end

    input_fn  = sprintf( '%sinput_j%d.mat', prefix_tmpdata, id_job);
    output_fn = sprintf('%soutput_j%d.mat', prefix_tmpdata, id_job);
    if s_b_launched(id_job)
      if ~exist([output_fn '.finished'], 'file')   % data is not ready
        pause(0.1/ncpu);             % save CPU time
        continue
      end
    else
      pause(0.1/ncpu);     % save CPU time, and do not push too fast
      if num_working >= ncpu 
        break;        % no enough CPU, wait for the launched ones
      end
      % save input parameters
      in = s_jobs{id_job};
      in.const_data = in_const_data;
      save('-v7', input_fn, 'id_job', 'in');
      if exist(output_fn, 'file')
        delete(output_fn);
      end
      if exist([output_fn '.finished'], 'file')
        delete([output_fn '.finished']);
      end
      % run the worker in background
      cmd = sprintf('%s "%s(''%s'', ''%s'')" > %s 2>&1 &',...
                   exec_name, func_name, input_fn, output_fn,...
                   [output_fn '.stdout']);
      system(cmd);
      num_working = num_working + 1;
      s_b_launched(id_job) = true;
      fprintf('id_job =%4d launched.\n', id_job);  fflush(stdout);
      continue
    end

    pause(0.05);
    % read result, then save it
    load(output_fn);
    if isfield(ou, 'need_postprocess')
      fprintf('id_job =%4d postprocessing.\n', id_job);  fflush(stdout);
      func_st = sprintf('%s(''%s'', ''%s'', ou.need_postprocess)',...
                   func_name, input_fn, output_fn);
      eval(func_st);  % execute in serial
      % load real result
      load(output_fn);
    end
    s_data{id_job} = ou;  % ou is loaded from output_fn

    % delete temporary files, to save disk space
    delete(input_fn);
    delete(output_fn);
    delete([output_fn '.finished']);
    num_working = num_working - 1;
    s_b_finished(id_job) = true;
    id_jobs_head = id_jobs_head + find(~s_b_finished(id_jobs_head:end), 1) - 1;
    fprintf('id_job =%4d finished.\n', id_job);  fflush(stdout);
  end  % for id_job
end  % while parallel

save('-v7', data_file_name, 's_data', 's_jobs', 'in_const_data');

if ~all(s_b_finished(:))
  disp('Warning: Not all works are done!!');
end

