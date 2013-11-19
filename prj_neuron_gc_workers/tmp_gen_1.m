%
mode_IF = 'IF';
mode_ST = 0;

%netstr = 'net_100_20';
%netstr = 'net_100_21';

%netstr = 'net_100_01';
%scee = 0.006;  scii = 0.006;
%pr = 0.24;  ps = 0.02;
%extst = '--RC-filter -seed 126';

%netstr = 'net_100_01';
%scee = 0.005;  scii = 0.009;
%pr = 0.24;  ps = 0.02;
%extst = '--RC-filter -seed 127';

%netstr = 'net_100_20';
%scee = 0.005;  scii = 0.009;
%pr = 0.24;  ps = 0.02;
%extst = '--RC-filter -seed 128';

%netstr = 'net_100_20';
%scee = 0.006;  scii = 0.006;
%pr = 0.24;  ps = 0.02;
%extst = '--RC-filter -seed 129';

netstr = 'net_100_21';
scee = 0.006;  scii = 0.006;
pr = 0.24;  ps = 0.02;
extst = '--RC-filter -seed 130';

simu_time = 1e6;
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
gendata_neu(netstr, sc, pr, ps, simu_time, stv, extst);

