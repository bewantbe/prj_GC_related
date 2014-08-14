% show result of parallel_main
pic_common_include;
t_ref = 2.0;  % ms
eE    = 14/3;
GL    = 0.05;
Gsigma = 2.0;  % ms
f_IF_freq = @(G) 1000*((GL+G)./(eE*G)<1)./(-log(1-(GL+G)./G/eE)./(GL+G) + t_ref);

% load results
s_data_file_name = {
'ISI_HH_pr=1.0_prps=1.0e-02~6.5e-02_t=1.00e+05'
'ISI_HH_pr=2.0_prps=1.0e-02~1.3e-01_t=1.00e+05'
'ISI_HH_pr=4.0_prps=1.0e-02~2.6e-01_t=1.00e+05'
'ISI_HH_pr=8.0_prps=1.0e-02~5.0e-01_t=1.00e+05'
'ISI_HH_pr=16.0_prps=1.0e-02~5.0e-01_t=1.00e+05'
'ISI_HH_pr=32.0_prps=1.0e-02~5.0e-01_t=1.00e+05'
'ISI_HH_pr=128.0_prps=1.0e-02~5.0e-01_t=1.00e+05'
};

s_color = ['m', 'g', 'c', 'k', 'b', 'r'];

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
  hd = legend(hd, sprintf('\\mu = %3gkHz', s_pr(1)), 'location', 'southeast');
  set(hd, 'fontsize', 16);
end
hold off
ylabel('spike rate /Hz');
xlabel('\mu\cdotf /1e-3');

pic_output_color('HH_gain_func_prps_pr');
