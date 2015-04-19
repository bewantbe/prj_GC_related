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
%n = 100, pr = 2
%'GCinfo_HH3_gcc_net_100_0X07E0EF5A_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 5%
%'GCinfo_HH3_gcc_net_100_0X1515715F_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_net_100_0X65763652_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_net_100_0X46DFF9E2_p=80,20_sc=0.05,0.05,0.09,0.09_pr=2_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%

%n = 50, pr = 1
%'GCinfo_HH3_gcc_net_50_0X7F4447F6_p=30,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  %  5%
%'GCinfo_HH3_gcc_net_50_0X626EDD5D_p=30,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_net_50_0X4BBD9C65_p=30,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_net_50_0X1A1C5C28_p=30,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40' %  20%

%n = 50, pr = 1, ST
%'GCinfo_HH3_gcc_ST_net_50_0X7F4447F6_p=30,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  %  5%
%'GCinfo_HH3_gcc_ST_net_50_0X626EDD5D_p=30,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_ST_net_50_0X4BBD9C65_p=30,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_ST_net_50_0X1A1C5C28_p=30,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40' %  20%

%n = 100, pr = 1
%'GCinfo_HH3_gcc_net_100_0X07E0EF5A_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  %  5%
%'GCinfo_HH3_gcc_net_100_0X1515715F_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_net_100_0X65763652_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_net_100_0X46DFF9E2_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%

%n = 100, pr = 1, ST
%'GCinfo_HH3_gcc_ST_net_100_0X07E0EF5A_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  %  5%
%'GCinfo_HH3_gcc_ST_net_100_0X1515715F_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_ST_net_100_0X65763652_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_ST_net_100_0X46DFF9E2_p=80,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%

%n = 100, pr = 1, volt, E
'GCinfo_HH3_gcc_net_50_0X1A1C5C28_p=50,0_sc=0.05,0.05,0,0_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%

%n = 200; pr = 1
%'GCinfo_HH3_gcc_net_200_0X0CD87C95_p=180,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  %  5%
%'GCinfo_HH3_gcc_net_200_0X4656EA6C_p=180,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_net_200_0X1416174F_p=180,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_net_200_0X26E90012_p=180,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%

%n = 200; pr = 1, ST
%'GCinfo_HH3_gcc_ST_net_200_0X0CD87C95_p=180,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  %  5%
%'GCinfo_HH3_gcc_ST_net_200_0X4656EA6C_p=180,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_ST_net_200_0X1416174F_p=180,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_ST_net_200_0X26E90012_p=180,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%

%n = 400; pr = 1
%'GCinfo_HH3_gcc_net_400_0X74F86E08_p=380,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  %  5%
%'GCinfo_HH3_gcc_net_400_0X6CB02912_p=380,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_net_400_0X168642DB_p=380,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_net_400_0X5EF21B69_p=380,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%

%n = 400; pr = 1, ST
%'GCinfo_HH3_gcc_ST_net_400_0X74F86E08_p=380,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  %  5%
%'GCinfo_HH3_gcc_ST_net_400_0X6CB02912_p=380,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc_ST_net_400_0X168642DB_p=380,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc_ST_net_400_0X5EF21B69_p=380,20_sc=0.05,0.05,0.09,0.09_pr=1_ps=0.03_stv=0.5_t=1.00e+06_od40'  % 20%

% not good example
%'GCinfo_LIF_icc_ST_net_100_0X1BD7844F_p=100,0_sc=0.0055,0,0,0_pr=1_ps=0.003_stv=0.5_t=1.00e+06_od30'
%'GCinfo_LIF_icc_ST_net_100_0X238CDEA7_p=100,0_sc=0.0055,0,0,0_pr=1_ps=0.003_stv=0.5_t=1.00e+06_od30'

%n = 1000; pr = 0.7, ps = 0.032, ST
%'GCinfo_HH3_gcc49_sparse_ST_net_1000_0X12A54BDF_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40'  % 2.5%, od=20
%'GCinfo_HH3_gcc49_sparse_ST_net_1000_0X51879353_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40'  % 5%
%'GCinfo_HH3_gcc49_sparse_ST_net_1000_0X5BC1ABB2_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc49_sparse_ST_net_1000_0X39A0FE1E_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40'  % 15%
%'GCinfo_HH3_gcc49_sparse_net_1000_0X29FBF1F4_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40'  % 20%

%n = 1000; pr = 0.7, ps = 0.032, volt
%'GCinfo_HH3_gcc49_sparse_net_1000_0X12A54BDF_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40'  % 2.5%
%'GCinfo_HH3_gcc49_sparse_net_1000_0X51879353_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40'  % 5%
%'GCinfo_HH3_gcc49_sparse_net_1000_0X5BC1ABB2_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40'  % 10%
%'GCinfo_HH3_gcc49_sparse_net_1000_0X29FBF1F4_p=750,250_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40'  % 20%

%n = 1000; pr = 0.7, ps = 0.032, volt, subnet = 1..100
%'GCinfo_HH3_gcc49_sparse_net_1000_0X51879353_p=100,0_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40_sub1t100'
%'GCinfo_HH3_gcc49_sparse_net_1000_0X5BC1ABB2_p=100,0_sc=0.04,0.04,0.07,0.07_pr=0.7_ps=0.032_stv=0.5_t=1.00e+06_od40_sub1t100'

};

fi.p_val            = 1e-5;
fi.use_od           = 40;  % 'aic'
fi.auto_gc_zero_cut = false;
fi.b_cal_net        = false;
fi.b_output_pics    = true;
fi.b_output_colorbar= false;
fi.gcdata_dir       = 'GCinfo/';

fi.b_use_pairGC     = false;
analyse_GCHH_big_p(s_case, fi, [], plot_settings);

return
fflush(stdout);

fi.b_use_pairGC     = true;
analyse_GCHH_big_p(s_case, fi, [], plot_settings);
