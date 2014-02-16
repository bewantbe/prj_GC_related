%

b_overlap_time_interval = false;

netstr = 'net_2_2';
scee = 0.01;
pr = 1.0;
ps = 0.012;
simu_time = 1e7;
stv0 = 0.125;
stv  = 1.0;

T_segment = 1000;
resample_mode = 'r';

extpara = '--RC-filter';
[oX, aveISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time, stv0, extpara);
[p, len] = size(oX);
mlen = T_segment/stv0;             % length of original data
slen = round(T_segment/stv);       % length of desired data
if exist('b_overlap_time_interval','var') && b_overlap_time_interval
    [X1,T1] = SampleNonUnif(oX, mlen, slen, resample_mode,...
                            simu_time/T_segment*stv/s_stv(1));
else
    [X1,T1] = SampleNonUnif(oX, mlen, slen, resample_mode);
end
fftlen = 2*mlen;
[S1, fqs] = mX2S_nuft(X1, (T1-1)/mlen, fftlen);
%[S1, fqs] = mX2S_nuft(X1, T1/mlen, fftlen);
fqs = fqs/T_segment;

figure(1);
fqss = fftshift(fqs);
S1s  = fftshift(S1);
plot(fqss, S1s(:,1,1));

