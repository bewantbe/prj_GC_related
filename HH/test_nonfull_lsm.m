%

%x = X(1,:);
x = X_l(1,:);

use_od = 50;
[~, ~, sa] = pos_nGrangerT2(x, use_od, 'qr');
res_x2 = filter([1, sa], [1], x-mean(x,2));

figure(11);
plot(srd(1, 1001:1400));
figure(12);
plot(res_x2(1001:1400));


%m = use_od;
%R = getcovpd(x, m);
%[p, m] = size(R);
%m = round(m/p)-1;

%RR = zeros(p,p*(2*m-1));
%RR(:, m*p-p+1:end) = R(:,1:m*p);
%for k = 1 : m-1
  %RR(:,(m-k)*p-p+1:(m-k)*p) = R(:,k*p+1:k*p+p)';
%end
%% construct the big covariance matrix
%covz = zeros(p*m, p*m);
%for k = 0 : m-1
  %covz(k*p+1:k*p+p, :) = RR(:, (m-k)*p-p+1 : (m+m-k)*p-p );
%end

R = getcovpd(x, use_od);

covz = getcovzpd(x, use_od);
b = covz(2:end, 1);
covz = covz(2:end, 2:end);

[u lm v] = svd(covz);
figure(15);
semilogy(diag(lm));

y = lm \ u'*b;
sa_est = - v * y;

% indicate the stability of the system
rs = roots(R);
figure(21);
%plot(rs,'*','markersize', 2, cos(0:0.01:2.01*pi), sin(0:0.01:2.01*pi));
%axis([-1.1,1.1,-1.1,1.1], 'square');
[~, sid] = sort(angle(rs));
rs = rs(sid);
plot(1-abs(rs),'.*','markersize', 2);

%fftlen = lowest_smooth_number_exact(sqrt(length(X)));
fftlen = use_od*2;
f_wnd = @(x) 0.5+0.5*cos(2*pi*x);  % seems the best choice
s = mX2S_wnd( bsxfun(@minus, x, mean(x,2)), [fftlen, 0.5], f_wnd);
h = S2X1D(s);
rh = roots(real(ifft(h)));
figure(22);
plot(rh,'*','markersize', 2, cos(0:0.01:2.01*pi), sin(0:0.01:2.01*pi));
axis([-1.1,1.1,-1.1,1.1], 'square');

[~, sid] = sort(angle(rh));
rh = rh(sid);
plot(1-abs(rh),'.*','markersize', 2);

