% Compare results and speed of two version of raster_tuning_HH program
% For developing faster HH simulator

% parameters to generate the network
net_param.generator  = 'gen_sparse';
net_param.p          = 100;
net_param.sparseness = 0.15;  % 0.30 0.20 0.15 0.10 0.05
net_param.seed       = 123;
net_param.software   = myif(exist('OCTAVE_VERSION','builtin'), 'octave', 'matlab');
gen_network = @(np) eval(sprintf('%s(np);', np.generator));

clear('pm');
pm.net_param = net_param;
pm.net  = gen_network(net_param);
pm.nI   = 20;
pm.scee = 0.05;
pm.scie = 0.07;
pm.scei = 0.09;
pm.scii = 0.09;
pm.pr   = 1.0;
pm.ps   = 0.03;
pm.t    = 2e3;
pm.stv  = 0.5;
pm.seed = 1;

%LIF model
%pmif = pm;
%pmif.neuron_model = 'LIF';
%pmif.scee = 0.0050;
%pmif.scie = 0.0068;
%pmif.scei = 0.0088;
%pmif.scii = 0.0088;
%pmif.ps   = 0.0060;
%[X1, ISI1, ras1] = gen_HH(pmif, 'rm');

%pm.neuron_model = 'HH3_gcc_t1';
pm.neuron_model = 'HH3_gcc49_s';
[X1, ISI1, ras1] = gen_HH(pm, 'rm');

pm.neuron_model = 'HH3_gcc';
%pm.scie *= (1+2e-16);
[X2, ISI2, ras2] = gen_HH(pm, 'rm');

if all(ISI1 == ISI2)
  disp('ISI counts are the same');
else
  disp('ISI counts are not the same');
  disp('First disagree:');
  id = find(ISI1-ISI2, 1);
  disp(ISI1(id));
  disp('  v.s.');
  disp(ISI2(id));
end

if size(ras1,1)==size(ras2,1) && 0==norm(ras1(:,1)-ras2(:,1))
  disp('RAS order is the same');
else
  disp('RAS not the same!!');
  disp('First disagree:');
  ras_l = min(size(ras1,1), size(ras2,1));
  id = find(ras1(1:ras_l,1)-ras2(1:ras_l,1), 1);
  disp(ras1(id,:));
  disp('  v.s.');
  disp(ras2(id,:));
  figure(3);
  j_mid = round(ras1(id,2)/pm.stv);
  rg = j_mid-50 : j_mid+400;
  rg(rg<1) = [];
  rg(rg>length(X1)) = [];
  plot(pm.stv*(rg - j_mid), X1([1,88], rg)');
end

if norm(X1-X2,'fro')==0
  disp('Data are exactly the same!');
end

%%%%%%%%
% plots

s_t = (1:length(X1))*pm.stv;

figure(1);
id_show_trace = [28];
plot(s_t, X1(id_show_trace,:), s_t, X2(id_show_trace,:));

figure(2);
id_show_trace = [28,68];
rg_bg = 1;
rg_ed = floor(1.0 * length(X1));
%plot(s_t(rg_bg:rg_ed), (X1(id_show_trace,rg_bg:rg_ed) - X2(id_show_trace,rg_bg:rg_ed))');
semilogy(s_t(rg_bg:rg_ed)', 1e-300+abs((X1(id_show_trace,rg_bg:rg_ed) - X2(id_show_trace,rg_bg:rg_ed))'));
ylim([1e-18, 10])

