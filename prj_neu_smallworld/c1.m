%

addpath('/home/xyy/matcode/octave-networks-toolbox');
addpath('/home/xyy/matcode/prj_neu_smallworld');

A_good = neu_network_guess;
A_bad = neu_network_guess;

results = {
'result_IF_net_100_rs01_sc=0.005_pr=1.00_ps=0.012_stv=0.50_t=1.00e+06.mat',...
'result_IF_net_100_rs01_sc=0.005_pr=1.00_ps=0.012_stv=7.50_t=1.00e+06.mat'
};

save('-v7', 'A_goog_bad.mat', 'A_bad', 'A_good', 'results');
save('-v7', 'A_goog_bad_p=1e-3.mat', 'A_bad', 'A_good', 'results');
save('-v7', 'A_goog_bad_p=1e-2.mat', 'A_bad', 'A_good', 'results');

avePathLength(A_good)

load('A_goog_bad.mat');
load('A_goog_bad_p=1e-3.mat');
load('A_goog_bad_p=1e-2.mat');

avePathLength(A_bad)
avePathLength(A_good)
clustering_coef_BDN(A_bad)
clustering_coef_BDN(A_good)

figure(15); plot_directional_graph(A_good,16,2);
figure(16); plot_directional_graph(A_bad,16,2);

adj2dot(A_good, 'A_good');
adj2dot(A_bad, 'A_bad');

total conn: 400
S=0.005  *7  
################################
#best possible
		good (0.5ms)	bad (7.5ms)
over guess: 	2		56
lack guess: 	0		225

aveLen		6.3270		Inf
clustering	0.43129		0.081355


################################
#p=1e-3
		good		bad
over guess: 	8		9
lack guess: 	0		307

aveLen		5.6038		Inf
clustering	0.41921		0.051222


################################
#p=1e-2
		good		bad
over guess:	92		103
lack guess:	0		196

aveLen		3.4848		Inf
aveLen(undir)	2.8669		3.0836
clustering	0.30351		0.085347

##
## net_100_rs01  p=80+20
##
################################
#p=1e-2
		1.0ms		5.0ms
over guess:	80		106
lack guess:	0		74

aveLen		3.6290		3.7214
aveLen(undir)	2.9616		2.8943
clustering	0.31183		0.20756

################################
#p=1e-3
sampt	over	lack	aveLen	aveLen(undir)	clustering
1.0ms	11	0	5.3747	4.1491		0.40903
2.0ms	12	0	5.5121	4.1267		0.40987
3.0ms	16	8	5.0591	3.9931		0.40388
4.0ms	11	83	Inf	4.3230		0.31269
5.0ms	6	159	Inf	5.7127		0.24537
6.0ms	9	392	Inf	Inf		0
7.0ms	8	355	Inf	Inf		0.011667
8.0ms	8	319	Inf	Inf		0.043135
9.0ms	14	295	Inf	Inf		0.047531


addpath('/home/xyy/matcode/octave-networks-toolbox');
addpath('/home/xyy/matcode/prj_neu_smallworld');
avePathLength(neu_network_guess)
avePathLength((neu_network_guess+neu_network_guess.')>0)
clustering_coef_BDN(neu_network_guess)


##############
#total random(400/9900)

aveLen		Inf		Inf
clustering	0.040169	0.039034	(E=0.040404)

##############
#regular (400/9900)

aveLen		12.879
clustering	0.50000



A=zeros(100);
while (sum(A(:))!=400)
  A=rand(100)<400/1e4; A(eye(100)==1)==0;
end
avePathLength (A)
clustering_coef_BDN(A)


n=100;
dg = @(k) diag(ones(1,n-abs(k)),k) + diag(ones(1,abs(k)),-sign(k)*(n-abs(k)));
adj = dg(2) + dg(-2) + dg(1) + dg(-1);
avePathLength (adj)
clustering_coef_BDN(adj)


0.01
0.195159704134586

0.001
0.217197165991903


		1.0ms		5ms

