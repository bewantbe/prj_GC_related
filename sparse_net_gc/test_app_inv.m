% test(find) approximation of inv toeplitz matrix

D = diag([0.9 1.0 0.8]);
A2d = [...
-0.8   0.0   0.0  0.5 -0.07   0.0;
 0.05 -0.9   0.0  0.0  0.8    0.0;
 0.0   0.04 -0.5  0.0  0.03   0.2];
p = size(D, 1);
fftlen = 8192;
S = A2S(A2d, D, fftlen);
S = StdWhiteS(S);
od = m = 990;
R = S2cov(S, od);

RGrangerT(R)

permvec = [1 2 3];
[Rvm, rvm] = covOrderMajor2VariableMajor(R, permvec);

m13r = cell2mat(rvm([1,3]));
m13R = cell2mat(Rvm([1,3],[1,3]));
m123r = cell2mat(rvm([1,2,3]));
m123R = cell2mat(Rvm);
GC_fomula = log(...
    (1 - m13r / m13R * m13r')/...
    (1 - m123r / m123R * m123r'))

Q = inv(m123R);
id_x = 1:m;
id_y = m+(1:m);
id_z = size(Q,1)-(m-1:0);
Qyy = Q(id_y, id_y);
Qxy = Q(id_x, id_y);
Qzy = Q(id_z, id_y);
iQyy = inv(Qyy);

QS = zeros(size(S));
for k = 1 : fftlen
  QS(:,:,k) = inv(S(:,:,k));
end
ift_Qxy = ifft(QS(1,2,:)(:),fftlen);

%od_forward = ceil(m/2);
%od_forward = 1;
od_forward = m-1;
% compare Q and QS
%figure(1); imagesc(Q - eye(size(Q)));
figure(2); plot(1:m, Qxy(od_forward+1,:), 1:m, shift(ift_Qxy, od_forward)(1:m));
figure(3); plot(1:m, Qxy(od_forward+1,:) - shift(ift_Qxy, od_forward)(1:m)');

%ift_iQS_yy = real( ifft(1 ./ QSp(2,2,:)(:), fftlen) );
%iQSp_yy = [ift_iQSp_yy, ift_iQSp_yy](fftlen-od_forward + (1:m));

