%

is_octave = exist('OCTAVE_VERSION','builtin') ~= 0;
if is_octave
%    font_size = 28;
  plot_settings.font_size = 22;
  plot_settings.line_width = 3;
else
  plot_settings.font_size = 24;
  plot_settings.line_width = 2;
end
plot_settings.visible = 'off';

s_case = {
%'GCinfo_HH3_gcc_net_100_0X07E0EF5A_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 5%
%'GCinfo_HH3_gcc_net_100_0X1515715F_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_net_100_0X65763652_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_net_100_0X46DFF9E2_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%

'GCinfo_HH3_gcc_net_100_0X07E0EF5A_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 5%
'GCinfo_HH3_gcc_net_100_0X1515715F_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
'GCinfo_HH3_gcc_net_100_0X65763652_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
'GCinfo_HH3_gcc_net_100_0X46DFF9E2_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%
};

fi.p_val            = 1e-5;
fi.use_od           = 'aic';
fi.auto_gc_zero_cut = false;
fi.b_cal_net        = false;
fi.b_output_pics    = true;
fi.gcdata_dir       = 'GCinfo/';

fi.b_use_pairGC     = false;
analyse_GCHH_big_p(s_case, fi, [], plot_settings);

fflush(stdout);

fi.b_use_pairGC     = true;
analyse_GCHH_big_p(s_case, fi, [], plot_settings);
