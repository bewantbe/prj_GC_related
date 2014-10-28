% test PDCAnalyzer.m

A2d = zeros(5,10);
A2d(1,1) =  0.95 * sqrt(2);
A2d(1,6) = -0.9025;
A2d(2,1) = -0.5;
A2d(3,7) =  0.4;
A2d(4,3) = -0.5;
A2d(4,4) =  0.25 * sqrt(2);
A2d(4,5) =  0.25 * sqrt(2);
A2d(5,4) = -0.25 * sqrt(2);
A2d(5,5) =  0.25 * sqrt(2);

A2d = -A2d;
p = size(A2d,1);
D = diag(ones(1, p));

X = gendata_linear(A2d, D, 1e5);

global g_figure_id
g_figure_id = 10;
[mpdc, ~, mdtf, ~] = PDCAnalyzer(X, 3);

srd = WhiteningFilter(X, 99);
global g_figure_id
g_figure_id = 20;
[mpdc, ~, mdtf, ~] = PDCAnalyzer(srd, 3);

