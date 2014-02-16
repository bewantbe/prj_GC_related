% show result of parallel_main
pic_common_include;
t_ref = 2.0;  % ms
eE    = 14/3;
GL    = 0.05;
Gsigma = 2.0;  % ms
f_IF_freq = @(G) 1000*((GL+G)./(eE*G)<1)./(-log(1-(GL+G)./G/eE)./(GL+G) + t_ref);

% load results
s_data_file_name = {
'ISI_pr=20.0_prps=5.5e-03~8.0e-03_t=1.00e+05.mat'
'ISI_pr=50.0_prps=5.5e-03~8.0e-03_t=1.00e+05.mat'
'ISI_pr=100.0_prps=5.5e-03~8.0e-03_t=1.00e+05.mat'
'ISI_pr=200.0_prps=5.5e-03~8.0e-03_t=1.00e+05.mat'
'ISI_pr=500.0_prps=5.5e-03~8.0e-03_t=1.00e+05.mat'
};

s_color = ['m', 'g', 'c', 'k', 'b', 'r'];

figure(1);
hold off
plot(5.5,0)
hold on

for id_s_data = 1:length(s_data_file_name)

  data_file_name = ['ISI_results/', s_data_file_name{id_s_data}];
  load(data_file_name);
  s_pr = zeros(size(s_jobs));
  s_ps = zeros(size(s_jobs));
  s_freq = zeros(size(s_jobs));
  s_freq_theory = zeros(size(s_jobs));
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    s_ps(id_job) = in.ps;
    s_pr(id_job) = in.pr;
    ou = s_data{id_job};
    s_freq(id_job) = 1000/ou.ISI;
    s_freq_theory(id_job) = f_IF_freq(Gsigma * in.pr * in.ps);
  end
  s_prps = s_ps.*s_pr;
  s_more_prps = linspace(s_prps(1),s_prps(end),1000);
  s_freq_theory = f_IF_freq(2*s_more_prps);

  hd = plot(s_prps/1e-3, s_freq, [s_color(id_s_data),'-o'],'markersize',2);
  legend(hd, sprintf('\\mu = %gkHz', s_pr(1)), 'location', 'northwest');
  %plot(s_prps/1e-3, s_freq, '-o','markersize',3,...
       %s_more_prps/1e-3, s_freq_theory, 'r-']);
end
hd=plot(s_more_prps/1e-3, s_freq_theory, 'r-');
legend(hd, 'current');
hold off
ylabel('spike rate /Hz');
xlabel('\mu\cdotf /1e-3');

pic_output_color('gain_func');
