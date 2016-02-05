% show result of parallel_main
pic_common_include;

% load results
s_data_file_name = {
'scan_scee_HH3_gcc49_westmere_pr=1.6_ps=4.0e-02_scee=5.0e-02-5.0e-02_t=1.0e+05.mat'
};

p = 2;
use_od = 20;

for id_s_data = 1:length(s_data_file_name)

  data_file_name = ['scan_scee_results/', s_data_file_name{id_s_data}];
  load(data_file_name);
  s_scee = zeros(size(s_jobs));
  s_freq = zeros(size(s_jobs), p);
  s_gc = zeros(numel(s_jobs), p);
  for id_job=1:numel(s_jobs)
    in = s_jobs{id_job};
    s_scee(id_job) = in.scee;
    ou = s_data{id_job};
    s_gc(id_job, :) = [ou.oGC(2, 1, use_od), ou.oGC(1, 2, use_od)];
    s_freq(id_job, :) = 1000 ./ ou.ISI;
  end

end

figure(1);
plot(s_scee, s_gc);

figure(2);
plot(s_scee, s_freq);

%pic_output_color('scee');
