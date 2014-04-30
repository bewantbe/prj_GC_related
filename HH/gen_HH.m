% Generate HH neuron data by calling external raster_tuning_HH
% Will use preserved data automatically

% gen_cmd   no data    have data   background(partial data)
% ''        gen+read   read        gen+read(overwrite)
% 'new'     gen+read   gen+read    gen+read(overwrite)
% 'nameX'   gen+name   name        gen+read(overwrite)
% 'read'    none       read        exit
% 'rm'      none       rm          none
% 'cmd'     print cmd for gen then exit
% background  gen&     none        gen&

% Usage example:
%{
  pm.net  = 'net_2_2';
  pm.ps   = 0.04;
  pm.pr   = 1.6;
  pm.scee = 0.05;
  pm.t    = 1e4;
  pm.dt   = 1/32;
  pm.stv  = 0.5;
  [X, ISI, ras] = gen_HH(pm);
%}

function [X, ISI, ras] = gen_HH(pm, gen_cmd, data_dir_prefix)
X=[];
ISI=[];
ras=[];

% Default settings
new_run    = false;
return_X_name = false;
mode_rm_only = false;
mode_read_only = false;
mode_run_in_background = false;
mode_print_cmd = false;
mode_show_cmd = false;
if ~exist('gen_cmd','var')
    gen_cmd = '';
end
gen_cmd = strtrim(gen_cmd);
while length(gen_cmd)>0
    [tok, gen_cmd] = strtok(gen_cmd, ' ,');
    switch tok
    case 'rm'
        mode_rm_only = true;         % remove the output files and exit
    case 'read'
        mode_read_only = true;
    case 'new'
        new_run = true;
    case 'nameX'
        return_X_name = true;        % return name of X data
    case 'cmd'
        mode_show_cmd = true;
    otherwise
        error(sprintf('no this option: "%s"', tok));
    end
end

% Default parameter values
if ~isfield(pm, 'net') || isempty(pm.net)
    pm.net = 'net_1_0'
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
    pm.dt = 0.5;
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
    pm.extra_cmd = '--RC-filter 0 1';  % default to no filter
end
s_tmp = strtrim(pm.extra_cmd);
if ~isempty(s_tmp) && strcmp(s_tmp(end), '&') == 1
    % start the data generation in background, then return immediately
    mode_run_in_background = true;  
end

% construct file paths
st_sc = strrep(mat2str([pm.scee, pm.scei, pm.scie, pm.scii]),' ',',');
st_p  = strrep(mat2str([pm.nE, pm.nI]),' ',',');
file_inf_st =...
    sprintf('%s_p%s_sc=%s_pr=%g_ps=%g_t=%.2e_stv=%g',...
            pm.net, st_p, st_sc, pm.pr, pm.ps, pm.t, pm.stv);
if ~exist('data_dir_prefix', 'var')
    data_dir_prefix = ['data', filesep];
end
file_prefix = [data_dir_prefix, 'HH_'];
output_name     = [file_prefix, 'volt_',file_inf_st,'.dat'];
output_ISI_name = [file_prefix, 'ISI_', file_inf_st,'.txt'];
output_RAS_name = [file_prefix, 'RAS_', file_inf_st,'.txt'];

% construct command string
pathdir = fileparts(mfilename('fullpath'));
st_neu_s =...
    sprintf('-scee %.16e -scei %.16e -scie %.16e -scii %.16e',...
            pm.scee, pm.scei, pm.scie, pm.scii);
st_neu_param =...
    sprintf('-n %d %d -mat %s -pr %.16e -ps %.16e %s',...
            pm.nE, pm.nI, mat_path, pm.pr, pm.ps, st_neu_s);
st_sim_param =...
    sprintf('-t %.16e -dt %.17e -stv %.17e',...
            pm.t, pm.dt, pm.stv);
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
    % fixme: is there a way to test whether the files are using by
    % other program in Matlab? lsof is not portable to M$
    % Whether the file is exist and filled?
    f_info = stat(output_RAS_name);
    if ~isempty(f_info) && (time() - f_info.mtime > 1.0)
        rt = 0;      % we have data
    else
        return
    end
end

% read and return data, if required
if rt==0
    if (nargout>0)
        if return_X_name
            X = output_name;
        else
            fid = fopen(output_name, 'r');
            X = fread(fid, [p, Inf], 'double');
            fclose(fid);
        end
    end
    if (nargout>1)
        ISI = load('-ascii', output_ISI_name);
    end
    if (nargout>2)
        % check if the file is non-empty
        tmp_fd = fopen(output_RAS_name);
        rt1 = fseek(tmp_fd, 0, 'eof');
        if rt1 ~= 0
            fclose(tmp_fd);
            error('fseek?');
        end
        pos = ftell(tmp_fd);
        fclose(tmp_fd);
        if pos > 1
            ras = load('-ascii', output_RAS_name);
        else
            ras = [];
        end
    end
else
    error('Fail to generate data!');
end

% delete data if asked
if mode_rm_only
    system([rmcmd, output_name]);
    system([rmcmd, output_ISI_name]);
    system([rmcmd, output_RAS_name]);
    return
end

end

%test
%{
  pm.net  = 'net_2_2';
  pm.ps   = 0.04;
  pm.pr   = 1.6;
  pm.scee = 0.05;
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

  [X] = gen_HH(pm, '');
  [X] = gen_HH(pm, '');
  [X] = gen_HH(pm, 'new');
  [X] = gen_HH(pm, 'rm');
  [X] = gen_HH(pm, 'new,rm');
  gen_HH(pm, '');
  gen_HH(pm, 'rm');

  gen_HH(pm,'');
  gen_HH(pm,'read');
  gen_HH(pm,'read,rm');

  X=gen_HH(pm,'nameX');
  X=gen_HH(pm,'nameX,rm');

  X=gen_HH(pm,'cmd');
}%

% vim: et sw=4 sts=4
