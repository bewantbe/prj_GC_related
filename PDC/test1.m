% Verify our partial coherence coefficent code
% Ref: L.A.Baccala, K. Sameshima(2001) Partial directed coherence: a new concept in neural structure determination

f_mean_sqr = @(c) real(mean( c.*conj(c), 3 ));

%{
S = A2S(A2d, D, fftlen);
S = StdWhiteS(S);
real(mean(S,3))
inv(real(mean(S,3)))
invS=zeros(size(S)); for k=1:size(S,3) invS(:,:,k)=inv(S(:,:,k)); end
real(mean(invS,3))
%}

fftlen = 1024;

%A2d=[
 %0.5  0.3 -0.4
%-0.5  0.3 -0.1
 %0.0 -0.3  0.2];  % same graph as the paper (Fig.1)
%A2d=[
% 0.5  0.3  0.4
%-0.5  0.3  1.0
% 0.0 -0.3 -0.2]; % same coefficients as the paper (Eq.(23))

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
S = A2S(A2d, D, fftlen);

%S = StdWhiteS(S);

m = 90;
R = S2cov(S, m);

pdc = PDC_R(R, fftlen);

fqn = 1:fftlen/2;
fqs = fqn / fftlen;

figure_id = 0;
figure(figure_id + 1);
for j = 1 : p
  for k = 1 : p
    subplot(p,p,(j-1)*p+k);
    area(fqs, abs(squeeze(pdc(j,k,fqn))));
    axis([0, 0.5, 0, 1]);
    set(gca, 'XTickLabel','');
    set(gca, 'XTick', []);
    set(gca, 'YTickLabel','');
    set(gca, 'YTick', []);
  end
end

%figure(figure_id + 3);
%imagesc( f_mean_sqr(pdc) );
%colorbar();

% 
dtf = DTF_R(R, fftlen);

figure(figure_id + 2);
for j = 1 : p
  for k = 1 : p
    subplot(p,p,(j-1)*p+k);
    area(fqs, abs(squeeze(dtf(j,k,fqn))));
    axis([0, 0.5, 0, 1]);
    set(gca, 'XTickLabel','');
    set(gca, 'XTick', []);
    set(gca, 'YTickLabel','');
    set(gca, 'YTick', []);
  end
end

%figure(figure_id + 4);
%imagesc( f_mean_sqr(dtf) );
%colorbar();

%X = gendata_linear(A2d, D, 1e5);
%PDCAnalyzer(X, 3);

%xx = zeros(p, fftlen);
%for j = 1 : p
%  for k = 1 : p
%    xx(j,:) += abs(squeeze(dtf(j,k,:))'.^2);
%  end
%end
%figure(3);
%plot(xx');

