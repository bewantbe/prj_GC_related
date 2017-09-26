% show result of parallel_main
pic_common_include;

% load results
prefix_tmpdata = 'ISI_test/';

%s_data_file_name = {
%'ISI_HH-GH_ps=0.05mV_prps=0.089-15mVkHz_t=1.00e+07'
%'ISI_HH-GH_ps=0.1mV_prps=0.089-15mVkHz_t=1.00e+07'
%'ISI_HH-GH_ps=0.2mV_prps=0.089-15mVkHz_t=1.00e+07'
%'ISI_HH-GH_ps=0.5mV_prps=0.089-15mVkHz_t=1.00e+07'
%'ISI_HH-GH_ps=1mV_prps=0.089-15mVkHz_t=1.00e+07'
%'ISI_HH-GH_ps=2mV_prps=0.089-15mVkHz_t=1.00e+07'
%};

%s_data_file_name = {
%'ISI_HH-GH_ps=0.05mV_prps=0.1-15mVkHz_t=1.00e+07_VT=65'
%'ISI_HH-GH_ps=0.1mV_prps=0.1-15mVkHz_t=1.00e+07_VT=65'
%'ISI_HH-GH_ps=0.2mV_prps=0.1-15mVkHz_t=1.00e+07_VT=65'
%'ISI_HH-GH_ps=0.5mV_prps=0.1-15mVkHz_t=1.00e+07_VT=65'
%'ISI_HH-GH_ps=1mV_prps=0.1-15mVkHz_t=1.00e+07_VT=65'
%'ISI_HH-GH_ps=2mV_prps=0.1-15mVkHz_t=1.00e+07_VT=65'
%};

%s_data_file_name = {
%'ISI_HH-G_ps=0.05mV_prps=0.1-15mVkHz_t=1.00e+07_VT=20'
%'ISI_HH-G_ps=0.1mV_prps=0.1-15mVkHz_t=1.00e+07_VT=20'
%'ISI_HH-G_ps=0.2mV_prps=0.1-15mVkHz_t=1.00e+07_VT=20'
%'ISI_HH-G_ps=0.5mV_prps=0.1-15mVkHz_t=1.00e+07_VT=20'
%'ISI_HH-G_ps=1mV_prps=0.1-15mVkHz_t=1.00e+07_VT=20'
%'ISI_HH-G_ps=2mV_prps=0.1-15mVkHz_t=1.00e+07_VT=20'
%};

s_data_file_name = {
'ISI_LIF-GH_ps=0.05mV_prps=0.16-4.5mVkHz_t=1.00e+07'
'ISI_LIF-GH_ps=0.1mV_prps=0.16-4.5mVkHz_t=1.00e+07'
'ISI_LIF-GH_ps=0.2mV_prps=0.16-4.5mVkHz_t=1.00e+07'
'ISI_LIF-GH_ps=0.5mV_prps=0.16-4.5mVkHz_t=1.00e+07'
'ISI_LIF-GH_ps=1mV_prps=0.16-4.5mVkHz_t=1.00e+07'
'ISI_LIF-GH_ps=2mV_prps=0.16-4.5mVkHz_t=1.00e+07'
};

%s_data_file_name = {
%'ISI_LIF-G_ps=0.05mV_prps=0.16-4.5mVkHz_t=1.00e+07'
%'ISI_LIF-G_ps=0.1mV_prps=0.16-4.5mVkHz_t=1.00e+07'
%'ISI_LIF-G_ps=0.2mV_prps=0.16-4.5mVkHz_t=1.00e+07'
%'ISI_LIF-G_ps=0.5mV_prps=0.16-4.5mVkHz_t=1.00e+07'
%'ISI_LIF-G_ps=1mV_prps=0.16-4.5mVkHz_t=1.00e+07'
%'ISI_LIF-G_ps=2mV_prps=0.16-4.5mVkHz_t=1.00e+07'
%};
s_prps_mV_local = 1.0;

figure(1);
hold off

cm = flipud(rainbow(length(s_data_file_name)));
%cm = rainbow(1+length(s_data_file_name))(1:end-1,:);

ss_ps_mV = zeros(size(s_data_file_name));

for id_s_data = 1:length(s_data_file_name)

  data_file_name = [prefix_tmpdata, s_data_file_name{id_s_data}, '.mat'];
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
  ss_ps_mV(id_s_data) = s_ps_mV(1);
%  hd = legend(hd, sprintf('f = %-5.2g mV', s_ps_mV(1)), 'location', 'southeast');
%  set(hd, 'fontsize', 18);
  if id_s_data == 1
    hold on
  end
end
hold off
ylabel('spike rate /Hz');
xlabel('\mu\cdotf (kHz\cdotmV(EPSP))');
%axis([0, s_prps_mV(end), 0, 100]);
xlim([0, s_prps_mV(end)]);

c_ps_mV = cell(size(ss_ps_mV));
for id_v = 1 : length(ss_ps_mV)
  c_ps_mV{id_v} = sprintf('f = %-5.2g mV', ss_ps_mV(id_v));
end

%hd = legend(hd, 'location', 'southeast');
%hd = legend(hd, c_ps_mV{:});
%set(hd, 'fontsize', 18);
%legend(hd, 'location', 'southeast');

hd = legend(c_ps_mV{:});
set(hd, 'fontsize', 18);
legend('location', 'southeast');

name_suffix = '';
if exist('in_const_data', 'var')
  pm = in_const_data.pm;
  if isfield(pm, 'extra_cmd') && ~isempty(strfind(pm.extra_cmd, '--set-threshold '))
    pos = strfind(pm.extra_cmd, '--set-threshold ') + length('--set-threshold ');
    name_suffix = ['_VT=' strtok(pm.extra_cmd(pos:end))];
  end
else
  pm.neuron_model = 'UNKNOWN';
end

pic_output_color(['Gain_func_prps_ps_mV_' pm.neuron_model name_suffix]);

if exist('s_prps_mV_local', 'var') && ~isempty(s_prps_mV_local)
  xlim([0, s_prps_mV_local]);
  legend('location', 'northwest');
  pic_output_color(['Gain_func_prps_ps_mV_' pm.neuron_model name_suffix '_local']);
end
