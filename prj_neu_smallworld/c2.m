
figure(15); plot_directional_graph(A_good,16,2);
figure(16); plot_directional_graph(A_bad,16,2);

adj2dot(A_good, 'A_good');
adj2dot(A_bad, 'A_bad');

addpath('/home/xyy/matcode/octave-networks-toolbox');
addpath('/home/xyy/matcode/prj_neu_smallworld');
avePathLength(neu_network_guess)
avePathLength((neu_network_guess+neu_network_guess.')>0)
clustering_coef_BDN(neu_network_guess)

#IF_net_100_rs01_sc=0.005_pr=1.00_ps=0.012_stv=3.00_t=1.00e+06

##
## net_100_rs01  p=100
##
#total conn: 400
#S=0.005
#p=1e-3
sampt	od	over	lack	aveLen	aveLen(undir)	clustering
idel				6.5			0.434
0.5ms	14(18)	8	0	5.6038	4.3125		0.41921
1.0ms	8(9)	4	0	5.9067	4.4778		0.42656
2.0ms	4(5)	4	0	5.8270	4.5576		0.42612
3.0ms	3(3)	8	8	5.4747	4.3388		0.41053
4.0ms	2(2)	9	85	Inf	4.3240		0.33421
5.0ms	2(3)	17	195	Inf	Inf		0.21720
6.0ms	1(3)	5	391	Inf	Inf		0
7.0ms	1(2)	9	351	Inf	Inf		0
7.5ms	1(2)	9	307	Inf	Inf		0.051222
8.0ms	1(1)	14	289	Inf	Inf		0.039135


p_val = 3e-4;
stv=1
over guess: 0
lack guess: 0

stv=6
over guess: 2
lack guess: 397

stv=8
over guess: 3
lack guess: 335


##
## net_100_rs01  p=80+20
##
#total conn: 400
#S=0.005
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




##############
#total random(400/9900)

aveLen		Inf		Inf		Inf
clustering	0.041637	0.036247	0.040539	(E=0.040404)

aveLen(undir)	Inf	3.3949	Inf	

##############
#regular (400/9900)

aveLen		12.879
aveLen(undir)	12.879
clustering	0.50000



A=zeros(100);
while (sum(A(:))!=400)
  A=rand(100)<400/1e4; A(eye(100)==1)==0;
end
avePathLength (A)
avePathLength ((A+A')>0)
clustering_coef_BDN(A)


A=zeros(100);
edge = zeros(1,100*99/2);
while (sum(edge)!=200)
  edge = rand(1,100*99/2) < 200/(100*99/2);
  A(tril(ones(100),-1) == 1) = edge;
end
A = (A+A.')>0;


n=100;
dg = @(k) diag(ones(1,n-abs(k)),k) + diag(ones(1,abs(k)),-sign(k)*(n-abs(k)));
adj = dg(2) + dg(-2) + dg(1) + dg(-1);
avePathLength (adj)
clustering_coef_BDN(adj)

