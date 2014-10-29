
pm = [];
pm.neuron_model = 'LIF';
pm.extra_cmd = '-q';

signature = [signature, '_', pm.neuron_model, myif(b_use_spike_train,'_ST','')];
save('-v7', [signature, '_info.mat'], 's_net', 's_time', 's_scee', 's_prps', 's_ps', 's_stv', 's_od', 'hist_div', 'maxod', 'b_use_spike_train', 'fftlen');

data_path_prefix = ['data/', signature, '_'];

for net_id = 1:length(s_net)
 netstr = s_net{net_id};
 neu_network = getnetwork(netstr);
 p = size(neu_network, 1);
for simu_time = s_time
for scee = s_scee
 prps_ps_stv_PDC = zeros(p, p, fftlen, length(s_prps), length(s_ps), length(s_stv));
 prps_ps_stv_oGC = zeros(p, p, length(s_od), length(s_prps), length(s_ps), length(s_stv));
 prps_ps_stv_oDe = zeros(p, p, length(s_od), length(s_prps), length(s_ps), length(s_stv));
 prps_ps_stv_R   = zeros(p, p*(maxod+1), length(s_prps), length(s_ps), length(s_stv));
 prps_ps_aveISI  = zeros(p, length(s_prps), length(s_ps));
 prps_ps_ISI_dis = zeros(p, length(hist_div), length(s_prps), length(s_ps));
 id_prps = 0;
for prps = s_prps
 id_prps = id_prps + 1;
 id_ps = 0;
for ps = s_ps
 id_ps = id_ps + 1;
 pr = prps / ps;
 pm.net = s_net{net_id};
 pm.scee = scee;
 pm.pr   = pr;
 pm.ps   = ps;
 pm.t    = simu_time;
 pm.dt   = s_dt;
 pm.seed = 'auto';
 disp(sprintf('ps %f, pr %f, prps %f',ps,pr,prps));  fflush(stdout);
 id_stv = 0;
for stv = s_stv
	id_stv = id_stv + 1;
        pm.stv = stv;
        [X, ISI, ras, pm] = gen_HH(pm, [], data_path_prefix);
        len = length(X);
        if b_use_spike_train
          X = SpikeTrains(ras, p, len, stv);
        end

        [oGC, oDe, R] = AnalyseSeries(X, s_od);

        prps_ps_stv_oGC(:,:,:, id_prps, id_ps, id_stv) = oGC;
        prps_ps_stv_oDe(:,:,:, id_prps, id_ps, id_stv) = oDe;
        prps_ps_stv_R  (:,:, id_prps, id_ps, id_stv) = R;

        [~, bic_od] = AnalyseSeries2(s_od, oGC, oDe, len);
        prps_ps_stv_PDC(:,:,:, id_prps, id_ps, id_stv) = PDC(X, bic_od);
end  % stv
	prps_ps_aveISI(:, id_prps, id_ps) = ISI;
	ISI_dis = zeros(p,length(hist_div));
	for kk = 1:p
		tm = ras(ras(:,1)==kk, 2);
		tm = tm(2:end) - tm(1:end-1);
		ISI_dis(kk,:) = hist(tm, hist_div);
	end
	prps_ps_ISI_dis(:,:,id_prps, id_ps) = ISI_dis;
  toc();
end  % ps
end  % prps
 datamatname = sprintf('%s_%s_sc=%.2g_t=%.1e.mat', signature,...
    netstr, scee, simu_time);
 save('-v7', datamatname, 'prps_ps_stv_oGC', 'prps_ps_stv_oDe', 'prps_ps_stv_R', 'prps_ps_aveISI', 'prps_ps_ISI_dis', 'prps_ps_stv_PDC');
 % save length ?
end  % scee
end  % simu_time
end  % net

