% test the transform that relate non-central Chi-Square to Gaussion distribution

n = 1e4;       % number of trials
m = 3;         % order (freedom degree)
sigma = 1.0;
mu    = 1.0;
x = sigma*randn(m, n)+mu;
x = sum((x./sigma).^2,1);  % non-central Chi-Square
lambda = m*(mu/sigma)^2;

dis_mean = lambda + m
mean(x)
dis_var  = 2*lambda + 4*m
var(x)
figure(1);
hist(x,100);

sq = @(x) sign(x).*sqrt(abs(x));
sf = @(x) sq(x-(m-1)/3);
%sf = @(x) sqrt(abs(x - (m-1)/3))
sum(x<(m-1)/3)

y = sf(x);  % so y is Gaussion distribution ?

figure(2);
[nn, xx] = hist(y,100);
bar(xx, nn/(numel(y)*(xx(2)-xx(1))));
hold on
px = -3:0.03:3;
plot(sqrt(lambda+(2*m+1)/3)+px, normpdf(px));
hold off

