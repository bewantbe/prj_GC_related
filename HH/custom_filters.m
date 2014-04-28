% test lowpass filter
%addpath ..
%addpath ../experimental_tools/

%d=fdesign.lowpass('Fp,Fst,Ap,Ast',0.2, 0.3, 0.5, 30);

%designmethods(d)
%Hda=design(d,'ALL'); %Lowpass FIR filter
%figure(9);
%fvtool(Hda(1));  % to verify the filter

%Hd=design(d,'equiripple'); %Lowpass FIR filter
%Hd=design(d,'IIR');
%disp('FIR order:');
%disp(num2str(length(Hd.Numerator)));

filter_id = 1;
% Choose a lowpass filter
switch filter_id
    case 1  % Butterworth, order=10, wc=0.25
        B = [   1.1055909917361822e-05   1.1055909917361822e-04   4.9751594628128198e-04   1.3267091900834188e-03   2.3217410826459825e-03   2.7860892991751788e-03   2.3217410826459825e-03   1.3267091900834188e-03   4.9751594628128198e-04   1.1055909917361822e-04   1.1055909917361822e-05];
        A = [   1.0000000000000000e+00  -4.9869852606501972e+00   1.1936436835234712e+01  -1.7742371809619303e+01   1.7973227969660318e+01  -1.2886241745934344e+01   6.5932022127934529e+00  -2.3690916911488880e+00   5.7063270555002665e-01  -8.3017678503865405e-02   5.5297143734627822e-03];
    case 2  % Chebyshev type I, order=10, wc=0.247, Apass=0.5dB
        B = [   3.1530278554903227e-07   3.1530278554903229e-06   1.4188625349706451e-05   3.7836334265883874e-05   6.6213584965296780e-05   7.9456301958356139e-05   6.6213584965296780e-05   3.7836334265883874e-05   1.4188625349706453e-05   3.1530278554903229e-06   3.1530278554903227e-07];
        A = [   1.0000000000000000e+00  -7.7171356972652809e+00   2.7991551133174678e+01  -6.2613541966654097e+01   9.5420596163558642e+01  -1.0335327811603918e+02   8.0496102922187831e+01  -4.4492272646071925e+01   1.6701894655585598e+01  -3.8467717802569430e+00   4.1319733308645495e-01];
    case 3  % Chebyshev type II,order=10, wstop=0.359, Astop=80dB
        B = [   1.1755336349270830e-03   8.4215183861153153e-04   3.4063262485957545e-03   3.3973398089154560e-03   5.1695412341857244e-03   4.9529426598517827e-03   5.1695412341857252e-03   3.3973398089154581e-03   3.4063262485957554e-03   8.4215183861153153e-04   1.1755336349270830e-03];
        A = [   1.0000000000000000e+00  -4.5620113770243798e+00   1.0254811261132312e+01  -1.4452850145207329e+01   1.3985002534812146e+01  -9.6221029024062172e+00   4.7432573876050323e+00  -1.6466961769658230e+00   3.8426138318004244e-01  -5.4253436857997973e-02   3.5161999225321364e-03];
    case 4  % Elliptic, order=10, wc=0.249, Apass=0.5dB, Astop=80dB
        B = [   6.8351890011103154e-04  -1.9127087290613989e-03   4.0111315471132161e-03  -5.0658985920014089e-03   5.9646197633074147e-03  -5.6070554516847075e-03   5.9646197633074155e-03  -5.0658985920014089e-03   4.0111315471132152e-03  -1.9127087290613989e-03   6.8351890011103154e-04];
        A = [   1.0000000000000000e+00  -7.4170848225746031e+00   2.6220131652785231e+01  -5.7717307953051694e+01   8.7231409097635549e+01  -9.4331438648797800e+01   7.3807459289158245e+01  -4.1233053481537638e+01   1.5743908038516860e+01  -3.7142331325194338e+00   4.1206817776440907e-01];
    case 5  % Equiripple, order=50, (Density Factor 20) wpass=0.213, wstop=0.313, Wpass=1, Wstop=1
        B = [   2.8933498448352013e-03   1.9849296870173842e-03   4.4332414899564681e-04  -2.2919927783407335e-03  -4.4243163288503872e-03  -3.8632517576589181e-03   7.9605733397174162e-05   5.5490102707330654e-03   8.7161341789316841e-03   6.1948649943671490e-03  -2.0696202708147178e-03  -1.1612284114480273e-02  -1.5447265421441415e-02  -8.6720332598750494e-03   7.0877626223675959e-03   2.2811936767033102e-02   2.6459982363183868e-02   1.0881948512414703e-02  -1.9354789666506653e-02  -4.7157309720611482e-02  -5.0056777796736181e-02  -1.2415759280693411e-02   6.3917881574676247e-02   1.5710300722980150e-01   2.3349031606861254e-01   2.6296226826199454e-01   2.3349031606861254e-01   1.5710300722980150e-01   6.3917881574676247e-02  -1.2415759280693411e-02  -5.0056777796736181e-02  -4.7157309720611482e-02  -1.9354789666506653e-02   1.0881948512414703e-02   2.6459982363183868e-02   2.2811936767033102e-02   7.0877626223675959e-03  -8.6720332598750494e-03  -1.5447265421441415e-02  -1.1612284114480273e-02  -2.0696202708147178e-03   6.1948649943671490e-03   8.7161341789316841e-03   5.5490102707330654e-03   7.9605733397174162e-05  -3.8632517576589181e-03  -4.4243163288503872e-03  -2.2919927783407335e-03   4.4332414899564681e-04   1.9849296870173842e-03   2.8933498448352013e-03];
        A = [1];
    % low order filters
    case 11 % Butterworth, order=2, wc=0.25
        B = [   9.7631072937817490e-02   1.9526214587563498e-01   9.7631072937817490e-02];
        A = [   1.0000000000000000e+00  -9.4280904158206336e-01   3.3333333333333343e-01];
    case 12 % Chebyshev type I, order=2, wc=0.209, Apass=1.0dB
        B = [   7.5911669308396823e-02   1.5182333861679365e-01   7.5911669308396823e-02];
        A = [   1.0000000000000000e+00  -1.1613597074239981e+00   5.0205688286755479e-01];
    case 13 % Chebyshev type II,order=2, wstop=0.880, Astop=50dB
        B = [   1.0040814067671738e-01   1.9363927013250049e-01   1.0040814067671738e-01];
        A = [   1.0000000000000000e+00  -9.3755733679394382e-01   3.3201288827987907e-01];
    case 14 % Elliptic, order=2, wc=0.209, Apass=1dB, Astop=40dB
        B = [   8.3034301506023186e-02   1.3940823339368147e-01   8.3034301506023186e-02];
        A = [   1.0000000000000000e+00  -1.1616431570131671e+00   5.0439380482217566e-01];
    case 15 % Equiripple, order=20, (Density Factor 20) wpass=0.221, wstop=0.321, Wpass=1, Wstop=1
        B = [   1.2307751079179193e-02   4.6818548146197826e-02   9.0058273761910290e-03  -1.0115084878178708e-02  -4.2599971067083020e-02  -5.1315589235729098e-02  -1.9368402864730728e-02   5.6720625674863454e-02   1.5519528454959014e-01   2.3837475328102969e-01   2.7091902185370703e-01   2.3837475328102969e-01   1.5519528454959014e-01   5.6720625674863454e-02  -1.9368402864730728e-02  -5.1315589235729098e-02  -4.2599971067083020e-02  -1.0115084878178708e-02   9.0058273761910290e-03   4.6818548146197826e-02   1.2307751079179193e-02];
        A = [1];
    otherwise
        error('no this method');
end

x=randn(1,1e7);
%y=filter(Hd.Numerator,1,x); %conventional filtering
y=filter(B,A,x); %conventional filtering

sx = X2Sxx(x, 1024);
sy = X2Sxx(y, 1024);

stv = 0.5;
fftlen = 1024;
s_fq = (0:fftlen-1)/fftlen /stv*1000;
%figure(1);
%plot(s_fq, sx);

figure(2);
plot(s_fq, sy);
axis([200 300 0 1.2]);

