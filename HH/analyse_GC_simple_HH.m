% Generate HH data

disp('----------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate data

mode_IF = 'IF';
mode_ST = 0;

netstr    = 'net_2_2';
scee      = 0.05;
pr        = 1.6;
ps        = 0.04;
simu_time = 1e6;
stv       = 0.5;
ext_T     = 1e4;

clear('pm');
pm.net  = netstr;
pm.ps   = ps;
pm.pr   = pr;
pm.scee = scee;
pm.t    = simu_time + ext_T;
pm.stv  = stv;
%pm.extra_cmd = [extst, '--save-poisson-events spe.txt'];

[X, ISI, ras] = gen_HH(pm);
X = X(:, round(ext_T/stv)+1:end);
if ~isempty(ras)
  ras(ras(:,2)<=ext_T, :) = [];
end
for id_p = 1:size(X,1)
  ISI(id_p) = simu_time/(sum(ras(:,1)==id_p,1));
end

oX = X;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% down sampling
i_stv = 2;
X = oX(:, 1:i_stv:end);
stv = pm.stv * i_stv;

if mode_ST
    [p, len] = size(X);
    clear('X');
    X = zeros(p,len);
    for neuron_id=1:p
        X(neuron_id,:) = SpikeTrain(ras, len, neuron_id, [], stv);
    end
end

% generate lowpass data
%[A, B] = custom_filters('butter_o=4_wc=0.1', true);
[A, B] = custom_filters('butter_o=2_wc=0.1', true);
%[A, B] = custom_filters(11, true);
X_l = filter(B',A',oX')';
X_l = X_l(:, 1:i_stv:end);

[p, len] = size(X);
fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
 netstr, scee, pr, ps, simu_time, stv, len);
disp('ISI:');
disp(ISI);

GC_basic_info(X, mode_IF);

% show volt and srd samples
test_filter_result;

