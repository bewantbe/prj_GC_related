% tests for AnalyseSeriesLevinson.m
addpath('/home/xyy/matcode/test/test_blocklevinson');

%pm=[];
%pm.neuron_model='LIF_icc';
%pm.t=1e6;
%pm.scee=0.01;
%pm.net='net_10_1';
%%pm.net='net_10_1';
%%pm.net='net_3_06';
%pm.pr=1;
%pm.ps=0.012;
%X = gen_HH(pm);

%data_dir_prefix = '/home/xyy/matcode/prj_GC_clean/data/';
%% most "studied" case, 20% connectivity, E
%pm = [];
%pm.neuron_model = 'LIF';
%pm.net  = 'net_100_01';
%pm.nI   = 0;
%pm.scee = 0.005;
%pm.pr   = 0.24;
%pm.ps   = 0.02;
%pm.t    = 1e6;
%X = gen_HH(pm, 'ext_T', data_dir_prefix);

%fR = getcovpdfile(X, 100, 20);

s_od = 1:20;
ma  = @(x) max(abs(x(:)));
ma2 = @(x) norm(x(:));
function_tic_flash = @(x,y) 0;
if exist('OCTAVE_VERSION','builtin')
  tocflash = @() function_tic_flash(fprintf('Elapsed time is %.3f seconds.\n',toc), fflush(stdout));
else
  tocflash = @() fprintf('Elapsed time is %.3f seconds.\n',toc());
end

%{
X=rand(200,1e6);

%tic
%[a_oGC, a_oDe, a_R] = AnalyseSeries(X, s_od);
%toc

fprintf('p=%d, len=%.1e\n', size(X,1), size(X,2));
fprintf('s_od = %d:%d\n', s_od(1), s_od(end));

fprintf('\ngetcovpd()\n');
tic
R = getcovpd(X, max(s_od));
tocflash();
clear('X');

%}

p = 20;
A = 0.0001*rand(p,2*p);
D = eye(p,p);
fftlen = 1024;
S = A2S(A, D, fftlen);
R = S2cov(S, max(s_od));
clear('S','A','D');

fprintf('\nAnalyseSeriesLevinson()\n');
tic
[c_oGC, c_oDe, c_R] = AnalyseSeriesLevinson(R, s_od, 1);
tocflash();
fprintf('\nAnalyseSeriesFast()\n');
tic
[b_oGC, b_oDe, b_R] = AnalyseSeriesFast(R, s_od, 1);
tocflash();

%fprintf('\n2-norm');
ma2(c_oGC - b_oGC)
ma2(c_oDe - b_oDe)

%ma2(a_oGC - b_oGC)
%ma2(a_oDe - b_oDe)

%fprintf('\nmax abs');
ma(c_oGC - b_oGC)
ma(c_oDe - b_oDe)

%ma(a_oGC - b_oGC)
%ma(a_oDe - b_oDe)

%
