% paper_hhgc_case_100_EI_pic

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
% paper_hhgc_case_100_EI_worker, volt
'GCinfo_HH3_gcc49_native_ST_net_100_0X69693679_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40_unif_s'
'GCinfo_HH3_gcc49_native_net_100_0X69693679_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40_unif_s'
};

fi.p_val            = 1e-4;
fi.use_od           = 40;  % 'aic'
fi.auto_gc_zero_cut = false;
fi.b_cal_net        = false;
fi.b_output_pics    = 2;
fi.gcdata_dir       = 'GCinfo/';

fi.b_use_pairGC     = false;
analyse_GCHH_big_p(s_case, fi, [], plot_settings);

return
fflush(stdout);

fi.b_use_pairGC     = true;
analyse_GCHH_big_p(s_case, fi, [], plot_settings);
