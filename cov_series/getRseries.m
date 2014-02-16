%

De = [1.0, 0.4; 0.4, 0.7];
A = [-0.9 ,  0.0, 0.5, 0.0;
     -0.16, -0.8, 0.2, 0.5];

%len = 1e5;
%X = gendata_linear(A,De,len, 1);
%od = 8;
%stat_R = getcovpd(X, od);
%covz = getcovzpd(X, 20);
%[A, De] = ARregressionpd(covz, 2);

[p mp] = size(A);
m = round(mp/p);

% theoretical Spectrum and Covs
fftlen = 2^8;
S = A2S_new(A,De,fftlen);
V_d3 = real(ifft(S, size(S,3), 3));
od_max = floor(fftlen/2);
R = reshape(V_d3(:,:,1:od_max),p,[]);

% another way to get cov
stv = 0.5;            % it's possible to calculate cov at non integer order
[s_lambda, s_V] = SolveARrecursion(A,De);
[s_lambda, s_V] = sortEigenAbs(s_lambda, s_V);
s_R = R_at_any_order(s_lambda, s_V, 0:stv:od_max);

smallchop = @(x) x = (abs(x)>5e-14) .* x;

di = 1;  % output formula for this element
dj = 2;
expr_V = cell(p,p);
expr_Vs = cell(1);
cnt = 1;
expr = 'expr_V{di,dj}=@(t) ';
for j=1:length(s_lambda)
  c = s_V(di,dj,j);
  c = smallchop(real(c)) + 1i * smallchop(imag(c));
  %c
  %s_lambda(j)
  if (abs(c)==0)
    continue
  end
  if iscomplex(s_lambda(j))
    if j<length(s_lambda) && isreal(s_lambda(j)+s_lambda(j+1))
      u = log(s_lambda(j));
      fprintf('exp(%g t) * 2*(%g cos(%g t) - %g sin(%g t))\n',
        real(u),real(c),imag(u),imag(c),imag(u));
      %fprintf('exp(%-9g t) * %-10g * cos(%-9g (t %-+9g))\n',
        %real(u),2*abs(c),imag(u),angle(c)/imag(u));
      expr0 = sprintf('%g * exp(%g*t) .* cos(%g * (t + %g))',
                      2*abs(c),real(u),imag(u),angle(c)/imag(u));
      expr=[expr sprintf('...\n+ ') expr0];
      eval(['expr_Vs{cnt} = @(t) ' expr0 ';']);
      cnt = cnt + 1;
    end
  else
    fprintf('exp(%g) * %g\n', log(s_lambda(j)), c);
  end
end
eval([expr, ';']);

% error
%for k = 0:od_max
  %norm((V_d3(:,:,1+k)-s_R(:,:,1+k)));
%end

%plot(squeeze(S(1,1,:)));
%plot(squeeze(V_d3(1,1,:)))

%figure(1)
%semilogy(abs(squeeze(V_d3(1,1,:))))
%semilogy(abs(squeeze(s_R(1,1,:))))

figure(2)
ed = 20;
rg_V = 1:ed;
rg_R = 1:round(ed/stv);
t = 0:0.1:ed;
%f = expr_V{di,dj};
y = zeros(0, length(t));
for k=1:length(expr_Vs)
  f = expr_Vs{k};
  %y = y + f(t);
  y = [y; f(t)];
end
%plot(rg_V-1, squeeze(V_d3(di,dj,rg_V)), '-+', (rg_R-1)*stv, squeeze(s_R(di,dj,rg_R)),'-o');
plot(rg_V-1, squeeze(V_d3(di,dj,rg_V)), '-+', (rg_R-1)*stv, squeeze(s_R(di,dj,rg_R)),'-o', t,y);

