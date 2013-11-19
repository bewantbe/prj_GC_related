%

if isempty(strfind(upper(signature),upper('expIF')))
  %s_prps_default = logspace(log10(4.9e-3), log10(4.7e-2), 30);
  dt_std = 1.0/32;
  model_mode = 'IF';
else
  %s_prps_default = logspace(log10(1.5e-3), log10(1.2e-1), 30);
  dt_std = 0.004;
  model_mode = 'EIF';
end

b_spike_train = isempty(strfind(upper(signature),upper('ST')))==1;  % using Spike Train?

p_select = length(s_neu_id);

for net_id = 1:length(s_net)
 netstr = s_net{net_id};
 neu_network = getnetwork(netstr);
 p = size(neu_network, 1);
for simu_time = s_time
for id_scee = 1:length(s_scee)
 if iscell(s_scee)
   scee = s_scee{id_scee};
 else
   scee = s_scee(id_scee);
 end
 prps_ps_stv_oGC = zeros(p_select, p_select, length(s_od), length(s_prps), length(s_ps), length(s_stv));
 prps_ps_stv_oDe = zeros(p_select, p_select, length(s_od), length(s_prps), length(s_ps), length(s_stv));
 prps_ps_stv_R   = zeros(p_select, p_select*(maxod+1), length(s_prps), length(s_ps), length(s_stv));
 prps_ps_aveISI  = zeros(p, length(s_prps), length(s_ps));
 prps_ps_ISI_dis = zeros(p, length(hist_div), length(s_prps), length(s_ps));
for id_prps = 1:length(s_prps)
 prps = s_prps(id_prps);
for id_ps = 1:length(s_ps)
 ps = s_ps(id_ps);
 pr = prps / ps;
for id_stv = 1:length(s_stv)
    stv = s_stv(id_stv);
    disp(sprintf('ps %f, pr %f, prps %f, stv %f',ps,pr,prps,stv));
    if exist('OCTAVE_VERSION','builtin')
        fflush(stdout);
    end
    if id_stv == 1     % actuall calculation
      extpara = '--RC-filter -seed 2673514932';
      if exist('pI','var') && pI>0
          extpara = [extpara,' -n ',num2str(pE),' ',num2str(pI)];
      end
      [oX, aveISI, ras] = gendata_neu(netstr, scee, pr, ps, simu_time, stv0, extpara);
      [p, len] = size(oX);
      mlen = T_segment/stv0;
      % read volt data, binary format
      if b_spike_train
          % get spike train
          len = round(simu_time/s_stv(1));
          oX = zeros(p,len);
          for neuron_id = 1:p
              st = SpikeTrain(ras, len, neuron_id, 1, stv);
              oX(neuron_id,:) = st;
          end
      end
    end

    tic();
    [oGC, oDe, R] = AnalyseSeries(oX(s_neu_id, 1:(stv/stv0):end), s_od);
    toc();

    prps_ps_stv_oGC(:,:,:, id_prps, id_ps, id_stv) = oGC;
    prps_ps_stv_oDe(:,:,:, id_prps, id_ps, id_stv) = oDe;
    prps_ps_stv_R  (:,:, id_prps, id_ps, id_stv) = R;
end  % stv
    prps_ps_aveISI(:, id_prps, id_ps) = aveISI;
    % get ISI distribution
    ISI_dis = zeros(p, length(hist_div));
%    ras = load('-ascii', output_RAS_name);
    for kk = 1:p
        tm = ras(ras(:,1)==kk, 2);
        tm = tm(2:end) - tm(1:end-1);
        ISI_dis(kk,:) = hist(tm, hist_div);
    end
    prps_ps_ISI_dis(:,:,id_prps, id_ps) = ISI_dis;
end  % ps
end  % prps
 if exist('pI','var') && pI>0
   datamatname = sprintf('%s_%s_p[%d,%d]_sc=[%g,%g,%g,%g]_t=%.3e.mat', signature, netstr, pE, pI, scee(1), scee(2), scee(3), scee(4), simu_time);
 else
   datamatname = sprintf('%s_%s_sc=%g_t=%.3e.mat', signature, netstr, scee, simu_time);
 end
 save('-v7', datamatname, 'prps_ps_stv_oGC', 'prps_ps_stv_oDe', 'prps_ps_stv_R', 'prps_ps_aveISI', 'prps_ps_ISI_dis');
 % save length ?
end  % scee
end  % simu_time
end  % net

% vim: set ts=4 sw=4 ss=4
