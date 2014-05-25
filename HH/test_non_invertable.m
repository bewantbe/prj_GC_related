%

len = 1e6;
x = randn(1, len);
%figure(1);
%show_spec(x);

%x1 = filter([1 1], 1, x);
%x1 = filter([1 2 1], 1, x);
x1 = filter([1 3 3 1], 1, x);
%x1 = filter([1 1.99 0.99], 1, x);

%figure(2);
%show_spec(x1);

% ues MA
%b = (-0.97).^(0:100);
%b1_len = 100;
%b = 1:-1/b1_len:0; b(end)=[];
%b = b.*(-1).^(0:length(b)-1);
%b = conv(b,b);
%figure(10);
%plot(b);
%x2 = filter(b, 1, x1);
%x2 = filter(b, 1, x2);

% use AR
%x2 = filter(1, [1 0.99], x1);
%x2 = filter(1, [1 1.99 0.99], x1);
%conv(conv([1 0.999],[1 0.999]),[1 0.999])
%x2 = filter(1, [1   2.997   2.994   0.997], x1);
%x2 = filter(1, [1 2 1], x1);
%x2 = filter(1, [1 3 3 1], x1);

% composition of AR
x2 = filter(1, [1 1-1e-5], x1);
x2 = filter(1, [1 1-1e-5], x2);
x2 = filter(1, [1 1-1e-5], x2);

figure(22);
show_spectrum(x2);

use_od = 100;
[xw, axw] = WhiteningFilter(x1,use_od);
figure(32);
show_spectrum(xw);

figure(99);
bg     = 1e5;
rg_len = 100;
rg     = bg:bg+rg_len-1;
plot([x(rg); x2(rg); xw(rg)]');

