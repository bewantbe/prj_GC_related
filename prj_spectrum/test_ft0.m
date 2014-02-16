% test spectrum

elen = 1000;
simu_time = 1e6;

%De = [1.0, 0.0; 0.0, 0.7];
%A = [-0.9 ,  0.0, 0.5, 0.0;
     %-0.016, -0.8, 0.02, 0.5];
%oX = gendata_linear(A, De, simu_time+elen);
%oX(:,1:elen) = [];

%oX = gendata_neu();
tic
oX = gendata_neu('net_2_2', 0.01, 1, 0.012, simu_time, 1.0, 'new -q -dt 0.125 --RC-filter');
toc; tic;

T_segment = 1e3;
stv0 = 1;
stv  = 1;

mlen = T_segment/stv0;
slen = round(T_segment/stv);
[X0,T0] = SampleNonUnif(oX, mlen, slen, 'u');
[Su, fqsu] = mX2S_ft(X0);
fqsu = fqsu/T_segment;

%Su = Makeup4SpectrumFact(Su);
fprintf('oX(%d) -> u(mlen=%d nslice=%d) -> mX2S_ft -> getGCSapp ',
        simu_time, mlen, simu_time/mlen);
[gc, de11, de22] = getGCSapp(Su); gc

HBW = 8;
n_taper = floor(2*HBW);
mlen = n_taper*T_segment/stv0;
slen = n_taper*round(T_segment/stv);
[X1,T1] = SampleNonUnif(oX, mlen, slen, 'u');
[S1 fqs] = mX2S_mt(X1, mlen, HBW, n_taper);
S1 = S1*2*4;
fqs = fqs/mlen;

%figure(1);
%plot(fftshift(fqs), fftshift(S1(:,1,1)), fftshift(fqsu), fftshift(Su(:,1,1)));

%S1 = Makeup4SpectrumFact(S1);
fprintf('oX(%d) -> u(mlen=%d nslice=%d) -> mX2S_mt(HBW=%g, ntaper=%d) -> getGCSapp ',
        simu_time, mlen, simu_time/mlen, HBW, n_taper);
[gc, de11, de22] = getGCSapp(S1); gc

%nGrangerT(oX,30)

use_od = 50;
srd = WhiteningFilter(oX, use_od);
srd = bsxfun(@rdivide, srd, var(srd')');
fprintf('oX(%d) -> Whitening (%d od) -> normalize var -> nGrangerT ', simu_time, use_od);
nGrangerT(srd, 50)

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
