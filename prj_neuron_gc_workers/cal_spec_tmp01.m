%
pic_common_include;

mode_IF = 'IF';
mode_ST = 0;
netstr = 'net_2_2';
scee = 0.02;
pr = 1.0;
ps = 0.012;
simu_time = 1e7;
stv = 1/16;
extst = '--RC-filter -seed 137598140';

X = gendata_neu(netstr, scee, pr, ps, simu_time, stv, extst);
%more_trials = ;
mlen = 256;
slen = 256;
tic;
X = SampleNonUnif(X, mlen, slen, 'u');
[aveS, fqs] = mX2S_ft(X);
toc;

fqs = fftshift(fqs);
aveS = fftshift(aveS,1);

figure(1);
%plot(fqs, aveS(:,1,1));
%pic_output_color('aveS11');

rg = ceil(slen/2+2):slen;
%plot(fqs(rg), aveS(rg,1,1));
%pic_output_color('aveS11');

loglog(fqs(rg), abs(aveS(rg,1,2)), fqs(rg), 0.04./fqs(rg).^2, fqs(rg), 0.6./fqs(rg).^3);
pic_output_color('aveS11');

