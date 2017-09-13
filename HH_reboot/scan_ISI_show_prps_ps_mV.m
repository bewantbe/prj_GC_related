% show result of parallel_main
pic_common_include;

% load results
s_data_file_name = {
'ISI_HH-GH_ps=2mV_prps=0.089-15mVkHz_t=1.00e+06'
};

figure(1);
hold off
plot(5.5,0)
hold on

cm = rainbow(length(s_data_file_name));
%cm = rainbow(1+length(s_data_file_name))(1:end-1,:);
for id_s_data = 1:length(s_data_file_name)

  data_file_name = ['ISI_results/', s_data_file_name{id_s_data}, '.mat'];
  load(data_file_name);
  
  s_pr    = zeros(size(s_jobs));
  s_ps_mV = zeros(size(s_jobs));
  s_freq  = zeros(size(s_jobs));
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    s_ps_mV(id_job) = in.ps_mV;
    s_pr   (id_job) = in.pr;
    ou = s_data{id_job};
    s_freq(id_job) = 1000 / ou.ISI;
  end
  s_prps_mV = s_ps_mV .* s_pr;

  hd = plot(s_prps_mV, s_freq, '-o', 'color',...
            cm(id_s_data,:), 'markersize', 2);
  hd = legend(hd, sprintf('f = %-5.2g mV', s_ps_mV(1)), 'location', 'southeast');
  set(hd, 'fontsize', 18);
end
hold off
ylabel('spike rate /Hz');
xlabel('\mu\cdotf (kHz\cdotmV(EPSP))');
axis([0, s_prps_mV(end), 0, 100]);
pic_output_color('Gain_func_prps_ps_mV');
