%
clear('stv','dt','extst');

mode_IF = 'IF';
mode_ST = 0;
netstr = 'net_2_2';
scee = 0.01;
pr = 1.0;
ps = 0.012;
simu_time = 1e6;
extst = '--RC-filter -seed 341432443';

if ~exist('extst','var')
    extst = '';
end
if strcmpi(mode_IF,'ExpIF')
    extst = ['ExpIF ',extst];
end
if exist('dt','var')
    extst = [extst, sprintf(' -dt %.16e',dt)];
end
if ~exist('stv','var')
    stv = 1/2;
end
[X, ISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time, stv, extst);

[p, len] = size(X);
X_st = zeros(p,len);
for neuron_id=1:p
    X_st(neuron_id,:) = SpikeTrain(ras, len, neuron_id);
end

if strcmpi(mode_IF,'IF')
    s_od = 1:99;  % for IF
else
    s_od = 1:499;  % for EIF
end

ba = basic_analyse(X, s_od);
ba_st = basic_analyse(X_st, s_od);

