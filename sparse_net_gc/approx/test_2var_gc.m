% two var test
pic_common_include;

%De = [1.0, 0.4; 0.4, 0.7];
%A = [-0.9 ,  0.0, 0.5, 0.0;
%     -0.16, -0.8, 0.2, 0.5];
%
%De = [0.7, 0.4; 0.4, 1.0];
%A = [-0.8,-0.16, 0.5, 0.2;
%      0.0, -0.9, 0.0, 0.5];
% scale noise
fa = sqrt(1/0.7);
De = [1.0, 0.2*fa; 0.2*fa, 1.0];
A = [-0.8,-0.16*fa, 0.5, 0.2*fa;
      0.0/fa, -0.9, 0.0/fa, 0.5];

p = size(A,1);

use_od = 50;
fftlen = 1024;
S = A2S(A, De, fftlen);
R = S2cov(S, use_od);

GC = RGrangerTfast(R)

% spectrum domain formula

A_f = fft(reshape([eye(p) A], p, p, []), fftlen, 3);

a = squeeze(A_f(1,1,:));
b = squeeze(A_f(1,2,:));
c = squeeze(A_f(2,1,:));
d = squeeze(A_f(2,2,:));

r = b./d;

gc_f = log(1 + abs(r).^2 ./ abs(1 - De(1,2) / De(1,1) * r).^2 * (De(2,2) - De(1,2)*De(2,1)/De(1,1)) / De(1,1));

mean(gc_f)

% simplified
gc_f_s = log(1 + 1 ./ abs(1 ./ r - De(1,2)).^2 * (1 - De(1,2)*De(2,1)));
mean(gc_f_s) - mean(gc_f)

figure(1); plot(gc_f_s);

% approximation core
figure(2);
Up = De(1,2);
Up2 = Up/(1-Up^2);
gc_f_core     = 1 ./  abs(1 ./ r - Up).^2 * (1 - Up*Up);
gc_f_core_app = 1 ./ (abs(1 ./ r - Up2).^2 + 1 - Up2*Up2);
gc_f_core_h = real(squeeze(S(1,1,:)) ./ (abs(d ./ (a.*d-b.*c)).^2)) - 1;

% search approximation
fq = (0:fftlen-1)/fftlen;

figure(1); plot(fq, gc_f_core, fq, gc_f_core_app);
xlabel('frequency');  ylabel('exp(GC(w))-1');  legend('f^{(linear)}_{y\rightarrowx|z}', 'f^{(app freq)}_{y\rightarrowx|z}');
pic_output_color('GC_f_core_2var_app');

figure(6); plot(gc_f_core, gc_f_core_app, [0 max(gc_f_core)], [0 max(gc_f_core)], '--');
xlabel('f^{(linear)}_{y\rightarrowx|z}');  ylabel('f^{(app freq)}_{y\rightarrowx|z}');
pic_output_color('GC_f_core_2var_cmp');

figure(2); plot(fq, gc_f_core, fq, 1 ./ (1 ./ gc_f_core_app - 1));
figure(3); plot(fq, gc_f_core, fq, (1-Up*Up) ./ (1 ./ gc_f_core_app - (1-Up2*Up2)));
figure(4); plot(fq, gc_f_core, fq, (1-Up*Up) ./ (1 ./ gc_f_core_app - (1/(1-Up^2)^2-Up2*Up2)));
figure(5); plot(fq, gc_f_core, fq, (1-Up*Up) ./ (1 ./ gc_f_core_app - (1/(1-Up*Up))));
xlabel('frequency');  ylabel('exp(GC(w))-1');  legend('f^{(linear)}_{y\rightarrowx|z}', 'g_\Upsilon (f^{(app freq)}_{y\rightarrowx|z})');
pic_output_color('GC_f_core_2var_app_modify');

% non-instantanious resistant
figure(10); plot(fq, gc_f_core, fq, gc_f_core_h);

