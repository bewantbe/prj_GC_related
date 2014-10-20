% show result of parallel_main
pic_common_include;

% load results
s_data_file_name = {
'ISI_HH_ps=0.065_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.032_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.016_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.008_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.004_prps=3.0e-03~5.0e-01_t=4.00e+05'
'ISI_HH_ps=0.002_prps=3.0e-03~5.0e-01_t=4.00e+05'
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
  s_pr = zeros(size(s_jobs));
  s_ps = zeros(size(s_jobs));
  s_freq = zeros(size(s_jobs));
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    s_ps(id_job) = in.ps;
    s_pr(id_job) = in.pr;
    ou = s_data{id_job};
    s_freq(id_job) = 1000/ou.ISI;
  end
  s_prps = s_ps.*s_pr;
  s_more_prps = linspace(s_prps(1),s_prps(end),1000);

  hd = plot(s_prps/1e-3, s_freq, '-o', 'color',...
            cm(id_s_data,:),'markersize',2);
  hd = legend(hd, sprintf('f = %g (%-5.2g mV)', s_ps(1), 31*s_ps(1)), 'location', 'southeast');
  set(hd, 'fontsize', 18);
end
hold off
ylabel('spike rate /Hz');
xlabel('\mu\cdotf /1e-3');

pic_output_color('HH_gain_func_prps_ps');

legend('location', 'northwest');
axis([0,100,0,30]);
pic_output_color('HH_gain_func_prps_ps_local');
