% Generate neuron data by calling external program
% will use preserved data automatically

% p the parameters
%{
  p.net = 'net_2_2';
  p.ps = 0.04;
  p.pr = 1.6;
  p.scee = 0.05;
  p.t = 1e5;
  p.dt = 1/32;
  p.stv = 0.5;
  [X, ISI, ras] = gen_HH(p);
%}

function [X, ISI, ras] = gen_HH(p)

output_name     = 'data/tmp_volt.dat';
output_ISI_name = 'data/tmp_isi.txt';
output_RAS_name = 'data/tmp_ras.txt';
[network, mat_path] = getnetwork(p.net);

st_neu_param = sprintf('-n %d -mat %s -pr %.16e -ps %.16e -scee %.16e',...
                       size(network,1), mat_path, p.pr, p.ps, p.scee);
st_sim_param = sprintf('-t %.16e -dt %.17e -stv %.17e',...
                       p.t, p.dt, p.stv);
st_paths = sprintf('-o %s --save-spike-interval %s --save-spike %s',...
                   output_name, output_ISI_name, output_RAS_name);
cmdst = sprintf('./raster_tuning_HH -ng -q -v %s %s %s',...
                st_neu_param, st_sim_param, st_paths);
disp(cmdst);

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
        ras = load('-ascii', output_RAS_name);
    end
else
    X=[];
    ISI=[];
    ras=[];
    error('Fail to generate data!');
end

end
% vim: set ts=4 sw=4 ss=4
