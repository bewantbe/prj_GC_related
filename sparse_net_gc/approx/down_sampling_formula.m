% test down sampling formula

pow2ceil = @(x) 2^ceil(log2(x));
maxerr = @(x) max(abs(x(:)));

fit_od = 40;
use_od = 200;
m = use_od;

ed = 0;
if ~exist('ed', 'var') || isempty(ed) || ~ed
  ed = true;

  %gen_data_n10_c1;
  %gen_data_n40_c1;  % 1 40
  gen_data_n100_c1;  % 32  32

  len = size(X,2);

  tic
  covz = getcovzpd(X, fit_od);  clear X
  toc
  [A2d, De] = ARregressionpd(covz, p);  clear covz

%  fa = sqrt(1/0.7);
%	De = [1.0, 0.4*fa; 0.4*fa, 1.0];
%	A2d = [-0.8,-0.16*fa, 0.5, 0.2*fa;
%		     0.0/fa, -0.9, 0.0/fa, 0.5];
%	p = size(A,1);

  fftlen = max(pow2ceil(8*use_od), 1024);
  S = A2S(A2d, De, fftlen);
%  S = StdWhiteS(S);
  R = S2cov(S, use_od);
  tic
  [GC De A2d] = RGrangerTfast(R);
  toc
end

A3d = reshape(A2d, p,p,[]);
A_even = -reshape(A3d(:,:,2:2:end), p, []);
A_odd  = -reshape(A3d(:,:,1:2:end), p, []);

R3d = reshape(R, p, p, []);

[GC_2 De_2 A2d_2] = RGrangerTfast(reshape(R3d(:,:,1:2:end), p, []));
A2d_2 = -A2d_2;

bigR = R2covz(R(:, 1:end-p));

% separate even and odd cov
ib_odd_od  = mod(floor((0:p*m-1)/p), 2) == 0;
ib_even_od = mod(floor((0:p*m-1)/p), 2) == 1;

% downsampling coef formula
B = A_even + A_odd * bigR(ib_odd_od, ib_even_od) / bigR(ib_even_od, ib_even_od);
maxerr(A2d_2 - B)

%{
% downsampling coef formula using inverse matrix
BigR_inv = inv(bigR);
B = A_even - A_odd / BigR_inv(ib_odd_od, ib_odd_od) * BigR_inv(ib_odd_od, ib_even_od);
maxerr(A2d_2 - B)

% verify solution
Ro = R(:, p+1:end);
maxerr(
[A_odd A_even] * [ ...
bigR(ib_odd_od, ib_odd_od)  bigR(ib_odd_od, ib_even_od)
bigR(ib_even_od,ib_odd_od)  bigR(ib_even_od,ib_even_od)] - ...
[Ro(:, ib_odd_od) Ro(:, ib_even_od)]
)
%}

% spectral squeeze (down sampling)
A_even_f = fft(reshape([eye(p) A_even], p,p,[]), fftlen/2, 3);
A_odd_f = fft(reshape([zeros(p) A_odd], p,p,[]), fftlen/2, 3);
B_f = fft(reshape([eye(p) B], p,p,[]), fftlen/2, 3);

U = 0.5*(S(:, :, 1:end/2) + S(:, :, (1:end/2) + end/2));
V = bsxfun(@times, ...
 reshape(0.5*exp(1i/2*2*pi*(0:fftlen/2-1)/(fftlen/2)), 1,1,[]), ...
 (S(:,:,1:end/2) - S(:,:,(1:end/2) + end/2)) ...
);
% verify
R_if = ifft(S, [], 3);
maxerr( fft(R_if(:,:,1:2:end), [], 3) - U )
maxerr( fft(R_if(:,:,2:2:end), [], 3) - V )

% Check fft formula temp step
tmp_A_f = mult3d(A_odd_f, V);
tmp_A_f = ifft(tmp_A_f, [], 3);
tmp_A_f = reshape(tmp_A_f(:,:,2:m/2+1), p,[]);
maxerr( tmp_A_f - A_odd * bigR(ib_odd_od, ib_even_od) )  % cool!

% verify spectral approximation
A_corr_f = rdiv3d(mult3d(A_odd_f, V), U);  % The spectral approximation
A_corr = ifft(A_corr_f, [], 3);
A_corr = A_corr(:,:,2:size(A_even,2)/size(A_even,1)-1);
A_corr = real(reshape(A_corr, p, []));

A_corr_ans = B - A_even;

figure(11); MatShow(A_corr_ans, -0.1);
figure(12); MatShow(A_corr, -0.1);

figure(13);
plot(1:fit_od, A_corr_ans(1, 1:p:fit_od*p), '-o', ...
     1:fit_od, A_corr(1, 1:p:fit_od*p), '-o', ...
     1:fit_od, A_even(1, 1:p:fit_od*p), '-o');

figure(14);
plot(1:fit_od, A_corr_ans(1, 2:p:fit_od*p), '-o', ...
     1:fit_od, A_corr(1, 2:p:fit_od*p), '-o', ...
     1:fit_od, A_even(1, 2:p:fit_od*p), '-o');

figure(15); plot(squeeze(U(1,1,:)));
figure(16); plot(squeeze(V(1,2,:)));

return

figure(1); MatShow(A2d, 0.01);
figure(2); MatShow(A2d_2, 0.01);
figure(3); MatShow(A_even, 0.01);
figure(4); MatShow(A_odd, 0.01);
figure(5); MatShow(B, 0.01);
figure(6); MatShow(bigR(ib_even_od, ib_even_od), 0.1);

