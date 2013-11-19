%
%set(0, 'defaultfigurevisible', 'off');

%s_signature = {'data_scan_stv/IF_net_100_rs01_w2'};
%ext_suffix = '_w2';

s_signature = {'data_scan_stv/IF_net_100_rs01_w2_p80_20_10neu'};
ext_suffix = '_w2_p80_20_10neu';

pic_prefix0 = 'pic_tmp/';

s_neu_show = [1:10];

    % loading parameters and data
    id_signature = 1;
        signature = s_signature{id_signature};
        load([signature, '_info.mat']);
        p_select = length(s_neu_id);
    id_net  = 1;
        netstr = s_net{id_net};
        neu_network = getnetwork(netstr);
        p = size(neu_network,1);
        sub_network = neu_network(s_neu_show,s_neu_show);
    id_time = 1;
        simu_time = s_time(id_time);
    id_scee = 1;
        if iscell(s_scee)
          scee = s_scee{id_scee};
        else
          scee = s_scee(id_scee);
        end
    id_prps = 1;
        prps = s_prps(id_prps);
    id_ps   = 1;
        ps = s_ps(id_ps);
        pr = prps / ps;
    if exist('pI','var') && pI~=0
      datamatname = sprintf('%s_%s_p[%d,%d]_sc=[%g,%g,%g,%g]_t=%.3e.mat', signature, netstr, pE, pI, scee(1), scee(2), scee(3), scee(4), simu_time);
    else
      datamatname = sprintf('%s_%s_sc=%g_t=%.3e.mat', signature, netstr, scee, simu_time);
    end
    load(datamatname);

    if isempty(strfind(lower(signature),lower('expIF')))
        pic_prefix = [pic_prefix0, 'IF'];
    else
        pic_prefix = [pic_prefix0, 'expIF'];
    end
    if ~isempty(strfind(lower(signature),lower('SpikeTrain')))
        pic_prefix = [pic_prefix, '_ST'];
    end
    if exist('pI','var') && pI~=0
        pic_prefix = sprintf('%s_%s_p[%d,%d]_sc=[%.4f,%.4f,%.4f,%.4f]_pr=%.4f_ps=%.4f_',...
            pic_prefix, netstr, pE, pI, scee(1), scee(2), scee(3), scee(4), pr, ps);
    else
        pic_prefix = sprintf('%s_%s_sc=%.4f_pr=%.4f_ps=%.4f_',...
            pic_prefix, netstr, scee, pr, ps);
    end
    pic_suffix = sprintf('_t=%.2e%s', simu_time, ext_suffix);
    pic_output_color = @(st)print('-depsc2',[pic_prefix, st, pic_suffix, '.eps']);


his1  = squeeze(prps_ps_ISI_dis(1:10,:,1,1));
phis1 = bsxfun(@rdivide, his1, sum(his1,2)) / (hist_div(2)-hist_div(1));
figure(21);  set(gca, 'visible', 'on');  set(gca, 'fontsize', 24);
plot(hist_div, phis1);
xlim([0,50]);
xlabel('ISI distribution of first 10 neurons (ms)')
ylabel('prob.');
pic_output_color('ISI_probs');


id_stv = 1;
stv = s_stv(id_stv);
idshowR = false(p_select, maxod+1);
idshowR(s_neu_show,:) = true;
idshowR = find(idshowR);
R   = prps_ps_stv_R  (s_neu_show,idshowR,   id_prps, id_ps, id_stv);

fftlen = 1024;
[gc,de,A] = RGrangerT(R);
S = A2S(A,de,fftlen);
fq = (0:fftlen-1)/fftlen * 1000/stv;

figure(22);  set(gca, 'visible', 'on');  set(gca, 'fontsize', 24);
sxx = transpose(permute(S,[3,1,2])(:,eye(p_select)==1));
plot(fq, real(sxx));
xlim([0,250]);
xlabel('Frequency/Hz');
ylabel('Spectrum');
pic_output_color('Sxx');

figure(23);  set(gca, 'visible', 'on');  set(gca, 'fontsize', 24);
sxy = transpose(permute(S,[3,1,2])(:,1==triu(ones(p_select),1)));
plot(fq, real(sxy), fq, imag(sxy));
xlim([0,250]);
xlabel('Frequency/Hz');
ylabel('Cross Spectrum');
pic_output_color('Sxy');

sR = reshape(R,p_select,p_select,[]);

figure(24);  set(gca, 'visible', 'on');  set(gca, 'fontsize', 24);
rxx = transpose(permute(sR,[3,1,2])(:,eye(p_select)==1));
rxx = bsxfun(@rdivide, rxx, rxx(:,1));
plot([0,s_od]*stv, rxx);
xlabel('time delay /ms');
ylabel('autocorrelation');
pic_output_color('Rxx');

figure(25);  set(gca, 'visible', 'on');  set(gca, 'fontsize', 24);
sR_full = cat(3, flipdim(permute(sR,[2,1,3]), 3), sR(:,:,2:end));
V = diag(1./sqrt(R(eye(p_select)==1)));
for t=1:size(sR_full,3)
    sR_full(:,:,t) = V * sR_full(:,:,t) * V;
end
rxy = transpose(permute(sR_full,[3,1,2])(:,1==triu(ones(p_select),1)));
plot([fliplr(-s_od),0,s_od]*stv, rxy);
xlabel('time delay /ms');
ylabel('cross correlation');
pic_output_color('Rxy');

