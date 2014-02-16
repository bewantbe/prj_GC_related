%

elen = 1000;
simu_time = 1e6;
%De = [1.0, 0.4; 0.4, 0.7];
%A = [-0.9 ,  0.0, 0.5, 0.0;
%     -0.16, -0.8, 0.2, 0.5];
De = [1.0, 0.0; 0.0, 1.0];
A = [-0.9 ,  0.0, 0.5, 0.0;
     -0.016, -0.8, 0.02, 0.5];

%tic();
%oX = gendata_linear(A, De, simu_time+elen);
%oX(:,1:elen) = [];
%toc();

S = A2S(A,De,1024);
R = S2cov(S,30);
RGrangerT(R)
S = permute(S,[3,1,2]);

getGCSapp(S)

