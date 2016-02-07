% Show GC v.s. order
%run('../HH/.octaverc');
%addpath('../HH');
run('~/matcode/GC_clean/.octaverc');
disp('----------------------------------------------------------');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate data
%{
mode_IF = 'IF';

netstr    = 'net_2_2';
scee      = 0.05;
pr        = 1.6;
ps        = 0.04;
simu_time = 1e5;
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
%}

addpath('/home/xyy/code/point-neuron-network-simulator/mfile');

pm = [];
%pm.neuron_model = 'HH-GH';  % one of LIF-G, LIF-GH, HH-GH
pm.neuron_model = 'LIF-G';
pm.net  = 'net_2_2';
pm.nI   = 0;
pm.scee = 0.010;
pm.scie = 0.00;
pm.scei = 0.00;
pm.scii = 0.00;
pm.pr   = 1.0;
pm.ps   = 0.012;
pm.t    = 1e5;
pm.dt   = 1.0/32;
pm.stv  = 0.5;
pm.seed = 'auto';
pm.extra_cmd = '';
[X, ISI, ras] = gen_neu(pm, 'new');

mode_IF = pm.neuron_model;
mode_ST = 1;

for id_p = 1:size(X,1)
  ISI(id_p) = pm.t/(sum(ras(:,1)==id_p,1));
end

oX = bsxfun(@minus, X, mean(X,2));  % better accuracy
%oX = X;

if mode_ST
    [p, len] = size(X);
    clear('X');
    X = zeros(p,len);
    for neuron_id=1:p
        X(neuron_id,:) = SpikeTrain(ras, len, neuron_id, [], pm.stv);
    end
    st_b_ST = '_ST_';
else
    st_b_ST = '';
end


[p, len] = size(X);
fprintf('net:%s, sc:%.3f, pr:%.2f, ps:%.4f, time:%.2e,stv:%.2f,len:%.2e\n',...
 pm.net, pm.scee, pm.pr, pm.ps, pm.t, pm.stv, len);
disp('ISI:');
disp(ISI);

max_od = 60;
[zero_GC, bic_od, aic_od] = GC_basic_info(X, max_od);

GC_regression;

j_bg = 0.31e5;
j_rg = j_bg+(1:200);
figure(3);
plot(pm.stv*(j_rg-j_bg), X(:, j_rg));
set(gca, 'fontsize', 24);
xlabel('t (millisecond)');
ylabel('voltage');
legend('x_t', 'y_t');
print('-depsc2', [mode_IF st_b_ST 'LIF-G-volt-example.eps']);

figure(4);
plot(pm.stv*(j_rg-j_bg), srd(:, j_rg));
set(gca, 'fontsize', 24);
xlabel('t (millisecond)');
ylabel('residual');
%legend('\epsilon^*_t', '\eta^*_t', 'location', 'southeast');
legend('\epsilon^*_t', '\eta^*_t');
print('-depsc2', [mode_IF st_b_ST '-volt-srd-example.eps']);

figure(1);
plot(pm.stv*(j_rg-j_bg), X(1, j_rg));
set(gca, 'fontsize', 24);
xlabel('t (millisecond)');
ylabel('voltage');
print('-depsc2', [mode_IF st_b_ST 'LIF-G-volt-1-example.eps']);

figure(2);
plot(pm.stv*(j_rg-j_bg), srd(1, j_rg));
set(gca, 'fontsize', 24);
xlabel('t (millisecond)');
ylabel('residual \epsilon^*_t');
print('-depsc2', [mode_IF st_b_ST '-volt-srd-1-example.eps']);

