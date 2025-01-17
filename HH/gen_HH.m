% Generate HH neuron data by calling raster_tuning_HH.exe
% Will use preserved data automatically
%
%  [X, ISI, ras, pm] = gen_HH(pm [, gen_cmd [, data_dir_prefix]])
%
% Usage example 1:       % the items with default value are optional
%  clear('pm');          % a new parameter set, or pm = [];
%  pm.neuron_model = 'HH2_gcc';  % program to run, with prefix raster_tuning_
%  pm.net  = 'net_2_2';  % can also be a connectivity matrix or full file path
%  pm.nI   = 0;          % default: 0. Number of Inhibitory neurons.
%                        %             Indexes are later half
%  pm.scee = 0.05;
%  pm.scie = 0.00;       % default: 0. Strength from Ex. to In.
%  pm.scei = 0.00;       % default: 0. Strength from In. to Ex.
%  pm.scii = 0.00;       % default: 0.
%  pm.pr   = 1.6;        % can be a vector
%  pm.ps   = 0.04;       % can be a vector
%  pm.t    = 1e4;
%  pm.dt   = 1.0/32;     % default: 1/32
%  pm.stv  = 0.5;        % default: 0.5
%  pm.seed = 'auto';     % default: 'auto'(or []). Accept integers
%  pm.extra_cmd = '';    % default: '--RC-filter 0 1'
%                        % put all other parameters here.
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
%  'ext_T'  Generate a bit more data, so reduce "head effect".
%
% return value pm is a "normalized" input parameter set

% Behaviour (parameter gen_cmd)
% gen_cmd   no data    have data   background(partial data)
% ''        gen+read   read        gen+read(overwrite)
% 'new'     gen+read   gen+read    gen+read(overwrite)
% 'nameX'   gen+name   name        gen+read(overwrite)
% 'read'    none       read        exit
% 'rm'      none       rm          none
% 'cmd'     print cmd for gen then exit
% 'ext_T'   
% background  gen&     none        gen&

function [X, ISI, ras, pm] = gen_HH(pm, gen_cmd, data_dir_prefix)
if nargin()==0
    disp(' [X, ISI, ras] = gen_HH(pm [, gen_cmd [, data_dir_prefix]])');
    disp(' Type "help gen_HH" for more help');
    error('Lack of input parameters.');
end
X=[];
ISI=[];
ras=[];
pm0 = pm;  % do a backup

% Default generator settings
new_run        = false;
return_X_name  = false;
mode_rm_only   = false;
mode_show_cmd  = false;
mode_read_only = false;
mode_run_in_background = false;
ext_T = 0;

% Read generator parameters
if ~exist('gen_cmd','var') || isempty(gen_cmd)
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
    case 'ext_T'
        ext_T = 1e3;            % extra calculation time
    otherwise
        error('no this option: "%s"', tok);
    end
end
pm.ext_T = ext_T;

% Default parameter values
if ~exist('data_dir_prefix', 'var')
    data_dir_prefix = ['.', filesep, 'data', filesep];
end
if ~isfield(pm, 'net') || isempty(pm.net)
    pm.net = 'net_1_0';
end
if ischar(pm.net)
    [network, mat_path] = getnetwork(pm.net, data_dir_prefix);
    [~, pm.net] = fileparts(pm.net);          % Use the name without extension
else
    % so pm.net is connectivity matrix?
    % save this matrix, so that it can be read by `raster_tuning'
    network = pm.net;
    [mat_path, pm.net] = savenetwork(pm.net, data_dir_prefix);
end
pm.net_path = mat_path;
pm.net_adj  = network;
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
if ~isfield(pm, 'scie') || isempty(pm.scie)
    pm.scie = 0;  % Strength from Ex. to In.
end
if ~isfield(pm, 'scei') || isempty(pm.scei)
    pm.scei = 0;  % Strength from In. to Ex.
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
if ~isfield(pm, 'neuron_model') || isempty(pm.neuron_model)
    % choose a faster simulator
    if p >= 24
        pm.neuron_model = 'HH3_gcc';
    else
        pm.neuron_model = 'HH2_icc';
    end
end
if all(pm.neuron_model(1:2) == 'HH')
  neuron_model_name = 'HH';
else
  neuron_model_name = 'LIF';
end

if ~isfield(pm, 'st_extra_inf_post')
    pm.st_extra_inf_post = '';
end

[pm, st_pr_mul_hash] = get_pm_mul_array(pm, 'pr');
[pm, st_ps_mul_hash] = get_pm_mul_array(pm, 'ps');
[pm, st_psi_mul_hash] = get_pm_mul_array(pm, 'psi');

% construct file paths
st_sc = strrep(mat2str([pm.scee, pm.scie, pm.scei, pm.scii]),' ',',');
st_p  = strrep(mat2str([pm.nE, pm.nI]),' ',',');
if isfield(pm,'psi')
    st_psi = sprintf('_psi=%g%s', pm.psi, st_psi_mul_hash);
else
    st_psi = '';
end
file_inf_st =...
    sprintf('%s_p=%s_sc=%s_pr=%g%s_ps=%g%s%s_stv=%g_t=%.2e',...
            pm.net, st_p(2:end-1), st_sc(2:end-1), pm.pr, st_pr_mul_hash,...
            pm.ps, st_ps_mul_hash, st_psi, pm.stv, pm.t + ext_T);
file_prefix = [data_dir_prefix, neuron_model_name, '_'];
output_name     = [file_prefix, 'volt_',file_inf_st,'.dat'];
output_ISI_name = [file_prefix, 'ISI_', file_inf_st,'.txt'];
output_RAS_name = [file_prefix, 'RAS_', file_inf_st,'.txt'];

% construct command string
%   consider use 'which raster_tuning_HH3_gcc.' to find path
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
pm.pr = pm0.pr;
if isfield(pm, 'pr_mul')
    if ~isfield(pm0, 'pr_mul')
        pm = rmfield(pm, 'pr_mul');
    else
        pm.pr_mul = pm0.pr_mul;
    end
end
pm.ps = pm0.ps;
if isfield(pm, 'ps_mul')
    if ~isfield(pm0, 'ps_mul')
        pm = rmfield(pm, 'ps_mul');
    else
        pm.ps_mul = pm0.ps_mul;
    end
end
if isfield(pm, 'psi')
    pm.psi = pm0.psi;
    if isfield(pm, 'psi_mul')
        if ~isfield(pm0, 'psi_mul')
            pm = rmfield(pm, 'psi_mul');
        else
            pm.psi_mul = pm0.psi_mul;
        end
    end
end
st_sim_param =...
    sprintf('-t %.16e -dt %.17e -stv %.17e',...
            pm.t + ext_T, pm.dt, pm.stv);
if isfield(pm, 'seed') && ~isempty(pm.seed) && strcmpi(pm.seed, 'auto')==0
    st_sim_param = [st_sim_param, sprintf(' -seed %d', pm.seed)];
else
    st_sim_param = [st_sim_param, ' --seed-auto-on'];
end
st_paths =...
    sprintf('--bin-save -o %s --save-spike-interval %s --save-spike %s',...
            output_name, output_ISI_name, output_RAS_name);
if pm.neuron_model(1) == '/'
  program_name = sprintf('%s', pm.neuron_model);
else
  program_name = sprintf('%s%sraster_tuning_%s',...
                         pathdir, filesep, pm.neuron_model);
end
if ~exist(program_name, 'file')
  error(['Can not find simulator! "' program_name '"']);
end
cmdst = sprintf('%s -ng -v -inf - %s %s %s %s',...
                program_name, st_neu_param, st_sim_param, st_paths, pm.extra_cmd);
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
        len = size(X,2);
        if len ~= floor((pm.t+ext_T)/pm.stv)
            warning('inconsistant data length!');
            fprintf('size(X,2) = %d, floor((pm.t+ext_T)/pm.stv) = %d\n',...
                    size(X,2), floor((pm.t+ext_T)/pm.stv));
        end
        len_cut = len - floor(pm.t/pm.stv);
        if (len_cut>0)
            X(:, 1:end-floor(pm.t/pm.stv)) = [];
        end
    end
    if (nargout>1)
        ISI = load('-ascii', output_ISI_name);
    end
    if (nargout>2)
        % We need to check if the file is non-empty (i.e. no any spike)
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
        if exist('len_cut','var') && len_cut>0 && ~isempty(ras)
            ras(ras(:,2) <= len_cut*pm.stv, :) = [];
            ras(:,2) = ras(:,2) - len_cut*pm.stv;
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

% transform pr/ps/psi array to pr_mul/ps_mul/psi_mul array
% field name should be pr/ps/psi
function [pm, st_mul_hash] = get_pm_mul_array(pm, field_name)
    st_mul_hash = '';
    if isfield(pm, field_name)
        f = getfield(pm, field_name);

        field_name_mul = [field_name, '_mul'];
        if numel(f) > 1.0
            nn = pm.nI + pm.nE;   % number of neurons
            if (numel(f) ~= nn)
                error('number of neurons inconsist with vector pr.');
            end
            % set f=1, represent different rates in f_mul.
            if isfield(pm, field_name_mul)
                f_mul = getfield(pm, field_name_mul);
                f_mul = [f_mul(:); ones(nn - numel(f_mul), 1)];
                f_mul = (f_mul .* f(:))';
            else
                f_mul = f;
            end
            f = mean(f_mul);      % so f is more informative
            f_mul = f_mul / f;
            pm = setfield(pm, field_name, f);
            pm = setfield(pm, field_name_mul, f_mul);
        end
        
        if isfield(pm, field_name_mul)
            f_mul = getfield(pm, field_name_mul);
            st_mul_hash = ['0X', BKDRHash(mat2str(f_mul))];
            pm = setfield(pm, [field_name_mul, '_hash'], st_mul_hash);
            st_mul_hash = ['-', st_mul_hash];
        end

    else
%        error('what?');
    end
end

%test
%{
  clear('pm');
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
