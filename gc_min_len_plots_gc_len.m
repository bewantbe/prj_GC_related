% plot the relation of gc and len_min
pic_common_include;

stv = 0.5;
s_od = [5, 10, 20, 40];
wantted_correct_rate = 0.9;

s_gc = linspace(0.5e-4, 1e-3, 20);
s_lmin = zeros(length(s_od), length(s_gc));
for k=1:length(s_gc)
  F1 = s_gc(k);
  for id_m=1:length(s_od)
    od = s_od(id_m);
    s_lmin(id_m, k) = solve_gc_min_len(od, F1, wantted_correct_rate);
  end
end

gc_scale = 1e-4;
figure(1);
s_tmin = s_lmin * stv / 1e3 / 60;
%plot(s_gc/gc_scale, s_tmin(2,:), 'o', s_gc/gc_scale, 34.563./s_gc * stv/1e3/60);
f_len_guess = @(od, F1) (1.153+sqrt(od-0.513)/1.917) * (10.002 ./ F1);
plot(s_gc/gc_scale, s_tmin, 'o', s_gc/gc_scale, f_len_guess(s_od', s_gc) * stv/1e3/60, '--');
xlabel(sprintf('GC / %.1e', gc_scale));
ylabel('time / min');
%legend('require time', '\~1/GC');
%pic_output_color(sprintf('gc_minT_m=%d_stv=%.2f', od, stv));
pic_output_color(sprintf('gc_minT_ms_stv=%.2f', stv));


F1 = 1e-4;
s_od = 1:99;
s_lmin = zeros(length(s_od), length(s_gc));
for id_m=1:length(s_od)
  od=s_od(id_m);
  s_lmin(id_m, 1) = solve_gc_min_len(od, F1, wantted_correct_rate);
end

figure(2);
plot(s_od, s_lmin(:,1)/1e5);
yl = ylim();  yl(1)=0;  ylim(yl);
xlabel('m');
ylabel('time / min');
pic_output_color(sprintf('gc_minT_ms_F1=%.2e_stv=%.2f', F1, stv));

