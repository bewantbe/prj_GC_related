% Show GC calculated from different method

simu_time = 1e6;
len_extra = 1000;
datalen = simu_time;

st_data_source = 'ar';

tic
switch st_data_source
  case 'ar'
    De = [1.0, 0.0; 0.0, 0.7];
    A = [-0.9 ,  0.0, 0.5, 0.0;
         -0.016, -0.8, 0.02, 0.5];
    oX = gendata_linear(A, De, simu_time+len_extra);
    oX(:,1:len_extra) = [];
  case 'neuron'
    oX = gendata_neu('net_2_2', 0.01, 1, 0.012, simu_time, 1.0, 'new -q -dt 0.125 --RC-filter');
  otherwise
    error('invalid value');
end
toc;
oX = bsxfun(@minus, oX, mean(oX,2));

% time domain GC (direct method)
use_od = chooseOrderAuto(oX);
fprintf('oX(%d) -> pos_nGrangerT2(oX, od=%d) -> getGCSapp ',
        simu_time, use_od);
gc = pos_nGrangerT2(oX, use_od); gc

% Welch's spectrum estimation
fftlen = round(sqrt(datalen)/2);
[Su, fqsu] = mX2S_wnd(oX, [fftlen, 0.6], @(x)1-2*abs(x));
fprintf('oX(%d) -> mX2S_wnd(fftlen=%d nslice=%d, wnd=1) -> getGCSapp ',
        simu_time, fftlen, simu_time/fftlen);
[gc, de11, de22] = getGCSapp(Su); gc

% Multi-taper spectrum estimation
HBW = 8;
n_taper = floor(2*HBW);
mlen = n_taper*round(sqrt(datalen));
slen = mlen;
[X1,T1] = SampleNonUnif(oX, mlen, slen, 'u');
[S1 fqs] = mX2S_mt(X1, mlen, HBW, n_taper);
S1 = S1*2*4;
fqs = fqs/mlen;
fprintf('oX(%d) -> u(mlen=%d nslice=%d) -> mX2S_mt(HBW=%g, ntaper=%d) -> getGCSapp ',
        simu_time, mlen, simu_time/mlen, HBW, n_taper);
[gc, de11, de22] = getGCSapp(S1); gc
%figure(1);
%plot(fftshift(fqs), fftshift(S1(:,1,1)), fftshift(fqsu), fftshift(Su(:,1,1)));

% time domain GC (whiten the data first)
use_od_whiten = 20;
use_od = 50;
srd = WhiteningFilter(oX, use_od);
srd = bsxfun(@rdivide, srd, var(srd')');
fprintf('oX(%d) -> Whitening(od=%d) -> normalize var -> nGrangerT(oX, od=%d) ',    simu_time, use_od_whiten, use_od);
gc = nGrangerT(srd, use_od); gc

%S = A2S(A,De,1024);
%S = permute(S,[3,1,2]);
%fprintf('exact S (1024) -> getGCSapp: ');
%getGCSapp(S)
%R = S2cov(S,50);
%fprintf('exact S (1024) -> R (50 od) -> RGrangerT: ');
%RGrangerT(R)

%msrd = SampleNonUnif(srd, mlen, slen, 'u');
%[rdS, fqsu] = mX2S_ft(msrd);
%figure(1);
%plot(real(rdS(:,1,2)))
toc
