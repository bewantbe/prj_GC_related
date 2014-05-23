% Generate HH neuron data by calling raster_tuning_HH.exe
% Will use preserved data automatically
%
%  [X, ISI, ras] = gen_HH(pm [, gen_cmd [, data_dir_prefix]])
%
% Usage example 1: % default means optional
%  clear('pm');          % a new parameter set
%  pm.net  = 'net_2_2';
%  pm.scee = 0.05;
%  pm.ps   = 0.04;
%  pm.pr   = 1.6;
%  pm.t    = 1e4;
%  pm.In   = 0;          % default: 0. Number of Inhibitory neurons.
%                        %             Indexes are later half
%  pm.dt   = 1.0/32;     % default: 1/32
%  pm.stv  = 0.5;        % default: 0.5
%  pm.seed = 'auto';     % default: 'auto'(or []). Accept integers
%  pm.scie = 0.00;       % default: 0. Strength from Ex. to In.
%  pm.scei = 0.00;       % default: 0. Strength from In. to Ex.
%  pm.scii = 0.00;       % default: 0.
%  pm.extra_cmd = '--RC-filter 0 1'  % default: '--RC-filter 0 1'
%                                    % put all other parameters here.
%  [X, ISI, ras] = gen_HH(pm);
%
% Usage example 2: Always re-generate data, then read it
%  X = gen_HH(pm, 'new');
%
% Usage example 3: Generate data if not exist, read it, then remove data files
%  X = gen_HH(pm, 'rm');
%
% Other possible values for "gen_cmd":
%  'read'   Read data files if exist, otherwise do nothing and return [];
%  'nameX'  return path to the voltage data file, instead of read it;
%  'cmd'    Show command call to raster_tuning_HH, then exit. Useful for debug

% Behaviour
% gen_cmd   no data    have data   background(partial data)
% ''        gen+read   read        gen+read(overwrite)
% 'new'     gen+read   gen+read    gen+read(overwrite)
% 'nameX'   gen+name   name        gen+read(overwrite)
% 'read'    none       read        exit
% 'rm'      none       rm          none
% 'cmd'     print cmd for gen then exit
% background  gen&     none        gen&

function [X, ISI, ras] = gen_HH(pm, gen_cmd, data_dir_prefix)
if nargin()==0
    disp(' [X, ISI, ras] = gen_HH(pm [, gen_cmd [, data_dir_prefix]])');
    disp(' Type "help gen_HH" for more help');
    error('Lack of input parameters.');
end
X=[];
ISI=[];
ras=[];

% Default settings
new_run        = false;
return_X_name  = false;
mode_rm_only   = false;
mode_show_cmd  = false;
mode_read_only = false;
mode_run_in_background = false;
if ~exist('gen_cmd','var')
    gen_cmd = '';
end
gen_cmd = strtrim(gen_cmd);
while ~isempty(gen_cmd)
    [tok, gen_cmd] = strtok(gen_cmd, ' ,');
    switch tok
    case 'rm'
        mode_rm_only = true;    % Remove specific data files then exit
    case 'read'
        mode_read_only = true;  % Read data files if there are, otherwise exit
    case 'new'
        new_run = true;         % Regenerate data and read it
    case 'nameX'
        return_X_name = true;   % Return file path of voltage data file
    case 'cmd'
        mode_show_cmd = true;   % Show the command to call, then exit
    otherwise
        error('no this option: "%s"', tok);
    end
end

% Default parameter values
if ~isfield(pm, 'net') || isempty(pm.net)
    pm.net = 'net_1_0';
end
[network, mat_path] = getnetwork(pm.net);
p = size(network,1);
if ~isfield(pm, 'nI') || isempty(pm.nI)
    pm.nI = 0;  % number of inhibitory neurons
end
if isfield(pm, 'nE') && ~isempty(pm.nE)
    if pm.nI + pm.nE ~= p
        error('gen_HH: Number of neurons inconsist with the network!');
    end
else
    pm.nE = p - pm.nI;
end
if ~isfield(pm, 'stv') || isempty(pm.stv)
    pm.stv = 0.5;
end
if ~isfield(pm, 'dt') || isempty(pm.dt)
    pm.dt = 1.0/32;
end
if ~isfield(pm, 'scee') || isempty(pm.scee)
    pm.scee = 0;
end
if ~isfield(pm, 'scei') || isempty(pm.scei)
    pm.scei = 0;
end
if ~isfield(pm, 'scie') || isempty(pm.scie)
    pm.scie = 0;
end
if ~isfield(pm, 'scii') || isempty(pm.scii)
    pm.scii = 0;
end
if ~isfield(pm, 'extra_cmd')
    pm.extra_cmd = '';
end
pm.extra_cmd = ['--RC-filter 0 1 ', pm.extra_cmd];  % default to no filter
s_tmp = strtrim(pm.extra_cmd);
if ~isempty(s_tmp) && strcmp(s_tmp(end), '&') == 1
    % start the data generation in background, then return immediately
    mode_run_in_background = true;  
end

% construct file paths
st_sc = strrep(mat2str([pm.scee, pm.scei, pm.scie, pm.scii]),' ',',');
st_p  = strrep(mat2str([pm.nE, pm.nI]),' ',',');
file_inf_st =...
    sprintf('%s_p=%s_sc=%s_pr=%g_ps=%g_t=%.2e_stv=%g',...
            pm.net, st_p(2:end-1), st_sc(2:end-1), pm.pr, pm.ps, pm.t, pm.stv);
if ~exist('data_dir_prefix', 'var')
    data_dir_prefix = ['data', filesep];
end
file_prefix = [data_dir_prefix, 'HH_'];
output_name     = [file_prefix, 'volt_',file_inf_st,'.dat'];
output_ISI_name = [file_prefix, 'ISI_', file_inf_st,'.txt'];
output_RAS_name = [file_prefix, 'RAS_', file_inf_st,'.txt'];

% construct command string
pathdir = fileparts(mfilename('fullpath'));
% ! NOTE: pm.scie is strength from Ex. to In. type
%         Seems biologist love this convention, I have no idea.
st_neu_s =...
    sprintf('-scee %.16e -scei %.16e -scie %.16e -scii %.16e',...
            pm.scee, pm.scie, pm.scei, pm.scii);
st_neu_param =...
    sprintf('-n %d %d -mat %s -pr %.16e -ps %.16e %s',...
            pm.nE, pm.nI, mat_path, pm.pr, pm.ps, st_neu_s);
st_neu_param = [st_neu_param, get_mul_st(pm, 'pr_mul')];
st_neu_param = [st_neu_param, get_mul_st(pm, 'ps_mul')];
st_neu_param = [st_neu_param, get_mul_st(pm, 'psi_mul')];
st_sim_param =...
    sprintf('-t %.16e -dt %.17e -stv %.17e',...
            pm.t, pm.dt, pm.stv);
if isfield(pm, 'seed') && ~isempty(pm.seed) && strcmpi(pm.seed, 'auto')==0
    st_sim_param = [st_sim_param, sprintf(' -seed %d', pm.seed)];
else
    st_sim_param = [st_sim_param, ' --seed-auto-on'];
end
st_paths =...
    sprintf('--bin-save -o %s --save-spike-interval %s --save-spike %s',...
            output_name, output_ISI_name, output_RAS_name);
cmdst = sprintf('%s%sraster_tuning_HH -ng -v %s %s %s %s',...
                pathdir, filesep, st_neu_param, st_sim_param, st_paths, pm.extra_cmd);
if mode_show_cmd
    disp(cmdst);
    return
end

if ispc()
    rmcmd = 'del ';    % need to check this
else
    rmcmd = 'rm -f ';
end

have_data = exist(output_RAS_name, 'file');
if (~have_data || new_run)...
   && ~mode_read_only...
   && (~mode_rm_only || mode_rm_only && nargout>0)
    % avoid data inconsistancy
    system([rmcmd, output_ISI_name]);
    system([rmcmd, output_RAS_name]);
    % generate data
    rt = system(cmdst);
    if mode_run_in_background
        ISI=rt;
        return
    end
else
    rt = 0;
end

if mode_read_only
    % Test if the file is exist and filled (modified more than 1 sec ago)?
    % Fixme: is there a way to test whether the files are using by
    %        other program in Matlab? lsof is not portable to M$ Windows
    % Note: dir().datenum only precise to seconds
    %       stat().mtime can precise to nano seconds, bug not in Matlab.
    %f_info = stat(output_RAS_name);
    %if ~isempty(f_info) && (time() - f_info.mtime > 1.0)
    f_info = dir(output_RAS_name);
    if ~isempty(f_info) && (datenum(clock()) - f_info.datenum > 1.0/86400)
        rt = 0;      % we have data
    else
        return
    end
end

if rt ~= 0
    error('Fail to generate data!');
end
% If required, read and return data
% At this point, the files should be generated, and ready for read.
if nargout > 0
    % Fixme: The Octave function isargout() is not in Matlab.
    %        So seems no way to skip non-required data in Matlab
    %        in some condition.
    if return_X_name
        X = output_name;
    else
        fid = fopen(output_name, 'r');
        X = fread(fid, [p, Inf], 'double');
        fclose(fid);
    end
    if (nargout>1)
        ISI = load('-ascii', output_ISI_name);
    end
    if (nargout>2)
        % Check if the file is non-empty (i.e. no any spike)
        % Otherwise load() may fail due to empty file.
        % TODO: use dir() in this part
        tmp_fd = fopen(output_RAS_name);
        rt1 = fseek(tmp_fd, 0, 'eof');
        if rt1 ~= 0
            fclose(tmp_fd);
            error('fail to call fseek(), check the file "%s"',...
                  output_RAS_name);
        end
        pos = ftell(tmp_fd);
        fclose(tmp_fd);
        if pos > 1
            ras = load('-ascii', output_RAS_name);
        else
            ras = [];
        end
    end
end

% delete data if asked
if mode_rm_only
    system([rmcmd, output_name]);
    system([rmcmd, output_ISI_name]);
    system([rmcmd, output_RAS_name]);
    return
end

end  % end of function

% Construct string for '--pr-mul', '--ps-mul', '--psi-mul'
function st = get_mul_st(pm, field_name)
    if isfield(pm, field_name)
        f = getfield(pm, field_name);
        if isnumeric(f)
            st = mat2str(f(:)');
            st = strrep(st,']','');
            st = strrep(st,'[','');
        elseif ischar(f)
            st = f;
        end
    else
        st = '';
    end
    st = strtrim(st);
    if ~isempty(st)
        st = [' --', strrep(field_name,'_','-'), ' ', st];
    end
end


%test
%{
  pm.net  = 'net_2_2';
  pm.scee = 0.05;
  pm.ps   = 0.04;
  pm.pr   = 1.6;
  pm.t    = 1e4;
  pm.dt   = 1/32;
  pm.stv  = 0.5;
  [X, ISI, ras] = gen_HH(pm);
  % no error

  pm.nE = 1;
  [X, ISI, ras] = gen_HH(pm);
  % Number of neurons inconsist with the network!

  pm.nI = 2;
  [X, ISI, ras] = gen_HH(pm);

  pm = rmfield(pm, 'nI');
  pm = rmfield(pm, 'nE');
  X = gen_HH(pm, '');
  X = gen_HH(pm, '');
  X = gen_HH(pm, 'new');
  X = gen_HH(pm, 'rm');  size(X)
  X = gen_HH(pm, 'new,rm');  size(X)
  gen_HH(pm, '');
  gen_HH(pm, 'rm');

  gen_HH(pm,'');
  gen_HH(pm,'read');
  gen_HH(pm,'read,rm');

  X=gen_HH(pm,'nameX');
  X=gen_HH(pm,'nameX,rm');

  X=gen_HH(pm,'cmd');
%}

% vim: et sw=4 sts=4
