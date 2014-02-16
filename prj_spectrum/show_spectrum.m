%
pic_common_include;

simu_time = 1e5;
stv0 = 0.125;
stv  = stv0;
T_segment = 1e3;

tic
%oX = gendata_neu('net_2_2', 0.01, 1, 0.012, simu_time, stv0, 'new -q -dt 0.125 --RC-filter');
toc; tic;

oX = s_V(1000:end,1:2)';
oX = bsxfun(@minus, oX, mean(oX,2));
simu_time = length(oX);
stv0 = 1;
stv  = 1;

T_segment = 1024;
mlen = T_segment/stv0;
slen = round(T_segment/stv);
[X0,T0] = SampleNonUnif(oX, mlen, slen, 'u');
[Su, fqsu] = mX2S_ft(X0);
fqsu = fqsu/mlen/stv0;
%Su = Makeup4SpectrumFact(Su);
fprintf('oX(%d) -> u(mlen=%d nslice=%d) -> mX2S_ft -> getGCSapp ',...
        simu_time, mlen, simu_time/mlen);
[gc, de11, de22] = getGCSapp(Su); gc

HBW = 8;
n_taper = floor(2*HBW);

T_segment = 1024;
HBW = 2;
n_taper = 2;
mlen = n_taper*T_segment/stv0;
slen = n_taper*round(T_segment/stv);
[X1,T1] = SampleNonUnif(oX, mlen, slen, 'u');
[S1 fqs] = mX2S_mt(X1, mlen, HBW, n_taper);
%S1 = S1*n_taper/64;
S1 = S1*2*n_taper*8;
fqs = fqs/mlen/stv0;
%Su = Makeup4SpectrumFact(Su);
fprintf('oX(%d) -> u(mlen=%d nslice=%d) -> mX2S_mt(HBW=%g, ntaper=%d) -> getGCSapp ',...
        simu_time, mlen, simu_time/mlen, HBW, n_taper);
[gc, de11, de22] = getGCSapp(S1); gc

figure(1);
%plot(fftshift(fqsu), fftshift(Su(:,1,1)), fftshift(fqs), fftshift(S1(:,1,1)));
semilogy(fftshift(fqsu), fftshift(Su(:,1,1)), fftshift(fqs), fftshift(S1(:,1,1)));
xlim([min(fqs), max(fqs)]);
pic_output_color(sprintf('ft_mt_s(1,1)'));

%figure(2);
%semilogy(fftshift(fqsu), abs(fftshift(Su(:,1,2))), fftshift(fqs), abs(fftshift(S1(:,1,2))));
%xlim([min(fqs), max(fqs)]);
%pic_output_color(sprintf('ft_mt_s(1,2)'));


%use_od = 50;
%srd = WhiteningFilter(oX, use_od);
%srd = bsxfun(@rdivide, srd, var(srd')');
%fprintf('oX(%d) -> Whitening (%d od) -> normalize var -> nGrangerT ', simu_time, use_od);
%nGrangerT(srd, 50)
toc
