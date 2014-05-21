% Show GC calculated from different method

simu_time = 1e5;
len_extra = 1000;
datalen = simu_time;

st_data_source = 'hh';

st_gen_cmd = 'new';
st_gen_cmd = '';
gc_scale = 1e4;

tic
switch st_data_source
  case 'ar'
    De = [1.0, 0.0; 0.0, 0.7];
    A = [-0.9 ,  0.0, 0.5, 0.0;
         -0.016, -0.8, 0.02, 0.5];
    oX = gendata_linear(A, De, simu_time+len_extra);
    oX(:,1:len_extra) = [];
  case 'if'
    oX = gendata_neu('net_2_2', 0.01, 1, 0.012, simu_time, 1.0, [st_gen_cmd ' -q -dt 0.125 --RC-filter']);
  case 'hh'
    pm.net  = 'net_2_2';
    pm.scee = 0.05;
    pm.ps   = 0.04;
    pm.pr   = 1.0;
    pm.t    = simu_time;
    pm.stv  = 1.0;
    oX = gen_HH(pm, st_gen_cmd);
  otherwise
    error('invalid value');
end
fprintf('t = %.3f (generate data)\n', toc);
oX = bsxfun(@minus, oX, mean(oX,2));

% time domain GC (direct method)
use_od = chooseOrderAuto(oX);
fprintf('oX(%d) -> pos_nGrangerT2(oX, od=%d) ',
        simu_time, use_od);
gc = pos_nGrangerT2(oX, use_od); gc_scale*gc

use_od_sgcapp = 50;

% freq GC, Welch's spectrum estimation
fftlen = round(sqrt(datalen));
[Su, fqsu winfo] = mX2S_wnd(oX, [fftlen, 0.6], @(x)1-2*abs(x));
fprintf('oX(%d) -> mX2S_wnd(mlen=%d nslice=%d, wnd) -> getGCSapp(od=%d) ',
        simu_time, fftlen, winfo.n_slices, use_od_sgcapp);
[gc, de11, de22] = getGCSapp(Su, use_od_sgcapp); gc_scale*gc

% freq GC, Multi-taper spectrum estimation
HBW = 4;
n_taper = floor(2*HBW-1);
mlen = 0.9*n_taper*round(sqrt(datalen));
[S1_mt fqs_mt winfo] = mX2S_mt(oX, mlen, HBW, n_taper);
fprintf('oX(%d) -> mX2S_mt(mlen=%d nslice=%d HBW=%g ntaper=%d) -> getGCSapp(od=%d) ',
        simu_time, mlen, winfo.n_slices, HBW, n_taper, use_od_sgcapp);
size(S1_mt)
%[gc, de11, de22] = getGCSapp(S1_mt, use_od_sgcapp); gc_scale*gc

figure(1);
plot(fftshift(fqs_mt), fftshift(S1_mt(:,1,1)), fftshift(fqsu), fftshift(Su(:,1,1)));
xlim([-0.5,0.5]);

% time domain GC (whiten the data first)
use_od_whiten = 20;
use_od = 50;
srd = WhiteningFilter(oX, use_od);
srd = bsxfun(@rdivide, srd, var(srd')');
fprintf('oX(%d) -> Whitening(od=%d) -> normalize var -> nGrangerT(oX, od=%d) ',    simu_time, use_od_whiten, use_od);
gc = nGrangerT(srd, use_od); gc_scale*gc

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
fprintf('t = %.3f (cal GCs)\n', toc);
