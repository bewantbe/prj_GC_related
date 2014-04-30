% Generate HH neuron data by calling external raster_tuning_HH
% Will use preserved data automatically

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
% Default settings
new_run    = false;
return_X_name = false;
mode_rm_only = false;
mode_read_only = false;
mode_run_in_background = false;
if ~exist('gen_cmd','var')
    gen_cmd = '';
end
if (length(gen_cmd)>=2) && (1==strcmpi(gen_cmd(1:2), 'rm'))
    mode_rm_only = true;         % remove the output files and exit
end
if (length(gen_cmd)>=4) && (1==strcmpi(gen_cmd(1:4), 'read'))
    mode_read_only = true;
end
if (length(gen_cmd)>=3) && (1==strcmpi(gen_cmd(1:3),'new'))
    new_run = true;
    gen_cmd = gen_cmd(4:end);
end
if (length(gen_cmd)>=5) && (1==strcmpi(gen_cmd(1:5),'nameX'))
    return_X_name = true;        % return name of X data
    gen_cmd = gen_cmd(6:end);
end


% Default values
if ~isfield(pm, 'net')
    pm.net = 'net_1_0'
end
[network, mat_path] = getnetwork(pm.net);
p = size(network,1);
if ~isfield(pm, 'nI')
    pm.nI = 0;  % number of inhibitory neurons
end
if isfield(pm, 'nE')
    if pm.nI + pm.nE ~= p
        error('gen_HH: Number of neurons inconsist with the network!');
    end
else
    pm.nE = p - pm.nI;
end
if ~isfield(pm, 'stv')
    pm.stv = 0.5;
end
if ~isfield(pm, 'dt')
    pm.dt = 0.5;
end
if ~isfield(pm, 'scee')
    pm.scee = 0;
end
if ~isfield(pm, 'scei')
    pm.scei = 0;
end
if ~isfield(pm, 'scie')
    pm.scie = 0;
end
if ~isfield(pm, 'scii')
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

st_sc = strrep(mat2str([pm.scee, pm.scei, pm.scie, pm.scii]),' ',',');
st_p  = strrep(mat2str([pm.nE, pm.nI]),' ',',');
file_inf_st =...
    sprintf('%s_p%s_sc=%s_pr=%g_ps=%g_t=%.2e_stv=%g',...
            pm.net, st_p, st_sc, pm.pr, pm.ps, pm.t, pm.stv);
if ~exist('data_dir_prefix', 'var')
    data_dir_prefix = ['data', filesep];
end
file_prefix = data_dir_prefix;
output_name     = [file_prefix, 'volt_',file_inf_st,'.dat'];
output_ISI_name = [file_prefix, 'ISI_', file_inf_st,'.txt'];
output_RAS_name = [file_prefix, 'RAS_', file_inf_st,'.txt'];

if ispc()
    rmcmd = 'del ';    % need to check this
else
    rmcmd = 'rm -f ';
end
if mode_rm_only
    system([rmcmd, output_name]);
    system([rmcmd, output_ISI_name]);
    system([rmcmd, output_RAS_name]);
    X = [];
    ISI = [];
    ras = [];
    return
end
if new_run
    system([rmcmd, output_ISI_name]);
    system([rmcmd, output_RAS_name]);
end

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
%disp(cmdst);

if (~exist(output_RAS_name, 'file') || new_run) && ~mode_read_only
    rt = system(cmdst);
else
    rt = 0;
end

if mode_run_in_background
    X=[];
    ISI=rt;
    RAS=[];
    return
end

if mode_read_only
    % fixme: is there a way to test whether the files are using by
    % other program in Matlab? lsof is not portable to M$
    % Whether the file is exist and filled?
    f_info = stat(output_RAS_name);
    if ~isempty(f_info) && (time() - f_info.mtime > 1.0)
        rt = 0;
    else
        X=[];
        ISI=[];
        ras=[];
        return
    end
end

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
    X=[];
    ISI=[];
    ras=[];
    error('Fail to generate data!');
end

end
% vim: et sw=4 sts=4
