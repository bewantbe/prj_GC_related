% Generate neuron data by calling external program
% will use preserved data automatically

% pm the parameters
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

function [X, ISI, ras] = gen_HH(pm)
return_X_name = false;

output_name     = 'data/tmp_volt.dat';
output_ISI_name = 'data/tmp_isi.txt';
output_RAS_name = 'data/tmp_ras.txt';
[network, mat_path] = getnetwork(pm.net);
p = size(network,1);

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
    pm.extra_cmd = '';
end

st_neu_s =...
    sprintf('-scee %.16e -scei %.16e -scie %.16e -scii %.16e',...
            pm.scee, pm.scei, pm.scie, pm.scii);
st_neu_param =...
    sprintf('-n %d -mat %s -pr %.16e -ps %.16e %s',...
            p, mat_path, pm.pr, pm.ps, st_neu_s);
st_sim_param =...
    sprintf('-t %.16e -dt %.17e -stv %.17e',...
            pm.t, pm.dt, pm.stv);
st_paths =...
    sprintf('--bin-save -o %s --save-spike-interval %s --save-spike %s',...
            output_name, output_ISI_name, output_RAS_name);
cmdst = sprintf('./raster_tuning_HH -ng -q -v %s %s %s %s',...
                st_neu_param, st_sim_param, st_paths, pm.extra_cmd);
%disp(cmdst);
disp('');

rt = system(cmdst);

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
