% simulation of HH model

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fixed parameters

% resting potential have been set to zero in the differential equations
% here indicate it origal value
V_rest = -65;

% capacitance volume, uF (/cm^2)
Cap = 1.0;  % I don't know...

% ion reversal potentials, mV
E_Na = 115;
E_K  = -12;
E_L  = 10.6;
% ion conductances, mS/cm2
g_Na = 120;
g_K  = 36;
g_L  = 0.3;

%func_slope = @(x) x./(exp(x)-1);
func_slope = @(x) (x~=0).*x./(exp(x)-1) + (x==0)*1;  % avoid fake singular, seems useless

alpha_m = @(u) func_slope(2.5-0.1*u);
beta_m  = @(u) 4*exp(-u/18);
alpha_h = @(u) 0.07*exp(-u/20);
beta_h  = @(u) 1./(exp(3-0.1*u)+1);
alpha_n = @(u) 0.1*func_slope(1-0.1*u);
beta_n  = @(u) 0.125*exp(-u/80);

tau_m = @(u) 1 ./ ( alpha_m(u) + beta_m(u) );
m_0   = @(u) alpha_m(u) .* tau_m(u);
tau_h = @(u) 1 ./ ( alpha_h(u) + beta_h(u) );
h_0   = @(u) alpha_h(u) .* tau_h(u);
tau_n = @(u) 1 ./ ( alpha_n(u) + beta_n(u) );
n_0   = @(u) alpha_n(u) .* tau_n(u);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simulation parameters

% external current input, in uA (/cm^2)
I_ext = @(u, t) 6.5 * (sign(t-0)+1)/2;         % step function, 2.3(start up), 6.24(continue)
%I_ext = @(u,t) 6.9 * (sign(t-10)+sign(11-t))/2;  % pulse function

I_ext = @(u, t) 11;

V0 = 0.0;                                % initial voltage
s_T = (0:1/8:20000)';                      % time steps
%sv0 = [V0, m_0(V0), h_0(V0), n_0(V0)];   % initial value for v, m, h, n
sv0 = [0, 0, 0, 0];   % initial value for v, m, h, n

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% solving dynamics
df_HH = @(x, t)([...
    -1/Cap*(g_Na*x(2)^3*x(3)*(x(1)-E_Na) + g_K*x(4)^4*(x(1)-E_K) + g_L*(x(1)-E_L)) + I_ext(x(1), t);...
    alpha_m(x(1))*(1-x(2)) - beta_m(x(1))*x(2);...
    alpha_h(x(1))*(1-x(3)) - beta_h(x(1))*x(3);...
    alpha_n(x(1))*(1-x(4)) - beta_n(x(1))*x(4)...
]);
tic;
if exist('lsode','file')==0
    [s_T, s_V] = ode45(@(t,x)df_HH(x,t), s_T, sv0);  % so we are in MATLAB
else
    s_V = lsode(df_HH, sv0, s_T);       % in octave
end
toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot
%rg = 1:round(length(s_T)/500):length(s_T);
rg = 1:length(s_T);

[~, t_id] = min(abs(s_T-12.8));

#    figure(1);
#    plot(s_T(t_id), s_V(t_id,1)+V_rest, 'r*', s_T(rg), s_V(rg,1)+V_rest, 'Linewidth',2);
#    sax=axis();  axis([sax(1), sax(2), -80, 40]);
#    xlabel('time /ms');  ylabel('voltage /mV');

    figure(1);
    plot(s_T(t_id), s_V(t_id,1), 'r*', s_T(rg), s_V(rg,1), 'Linewidth',2);
    sax=axis();  axis([sax(1), sax(2), -80+65, 40+65]);
    xlabel('time /ms');  ylabel('voltage /mV');

    figure(2);
    plot(s_T(t_id),s_V(t_id,3),'b*', s_T(rg), s_V(rg,3),'b',...
         s_T(t_id),s_V(t_id,4),'r*', s_T(rg), s_V(rg,4),'r')
    xlabel('time /ms');
    legend('h','n');

