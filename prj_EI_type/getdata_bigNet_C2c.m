% generate case C2

mode_IF = 'IF';
mode_ST = 1;
netstr = 'net_100_21';
scee = 0.005;  scii = 0.007;
pr = 1.0;
ps = 0.012;
simu_time = 1e6;
extst = '--RC-filter -seed 131';

pE = 80;
pI = 20;
sc = [scee, scee, scii, scii];
extst = [extst,' -n ',num2str(pE),' ',num2str(pI)];

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
[X, ISI, ras] = gendata_neu(netstr, sc, pr, ps, simu_time, stv, extst);

if mode_ST
    [p, len] = size(X);
    clear('X');
    X = zeros(p,len);
    for neuron_id=1:p
        X(neuron_id,:) = SpikeTrain(ras, len, neuron_id);
    end
end

