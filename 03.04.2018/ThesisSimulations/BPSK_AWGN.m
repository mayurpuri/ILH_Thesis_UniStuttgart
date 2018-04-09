%clear; %clear all stored variables
N=100; %number of data bits
noiseVariance = 0.5; %Noise variance of AWGN channel
data=randn(1,N)>=0; %Generate uniformly distributed random data
Rb=1e3; %bit rate
amplitude=1; % Amplitude of NRZ data
[time,nrzData,Fs]=NRZ_Encoder(data,Rb,amplitude,'Polar');
Tb=1/Rb;
subplot(4,2,1);
stem(data);
xlabel('Samples');
ylabel('Amplitude');
title('Input Binary Data');
axis([0,N,-0.5,1.5]);
subplot(4,2,3);
plotHandle=plot(time,nrzData);
xlabel('Time');
ylabel('Amplitude');
title('Polar NRZ encoded data');
set(plotHandle,'LineWidth',2.5);
maxTime=max(time);
maxAmp=max(nrzData);
minAmp=min(nrzData);
axis([0,maxTime,minAmp-1,maxAmp+1]);
grid on;
Fc=2*Rb;
osc = sin(2*pi*Fc*time);
%BPSK modulation
bpskModulated = nrzData.*osc;
subplot(4,2,5);
plot(time,bpskModulated);
xlabel('Time');
ylabel('Amplitude');
title('BPSK Modulated Data');
maxTime=max(time);
maxAmp=max(nrzData);
minAmp=min(nrzData);
axis([0,maxTime,minAmp-1,maxAmp+1]);
%plotting the PSD of BPSK modulated data
%subplot(4,2,7);
%h=spectrum.welch; %Welch spectrum estimator
%Hpsd = psd(h,bpskModulated,'Fs',Fs);
%plot(Hpsd);
%title('PSD of BPSK modulated Data');
%-------------------------------------------
%Adding Channel Noise
%-------------------------------------------
noise = sqrt(noiseVariance)*randn(1,length(bpskModulated));
received = bpskModulated + noise;
subplot(4,2,2);
plot(time,received);
xlabel('Time');
ylabel('Amplitude');
title('BPSK Modulated Data with AWGN noise');
%-------------------------------------------
%BPSK Receiver
%-------------------------------------------
%Multiplying the received signal with reference Oscillator
v = received.*osc;
%Integrator
integrationBase = 0:1/Fs:Tb-1/Fs;
for i = 0:(length(v)/(Tb*Fs))-1
y(i+1)=trapz(integrationBase,v(int32(i*Tb*Fs+1):int32((i+1)*Tb*Fs)));
end
%Threshold Comparator
estimatedBits=(y>=0);
subplot(4,2,4);
stem(estimatedBits);
xlabel('Samples');
ylabel('Amplitude');
title('Estimated Binary Data');
axis([0,N,-0.5,1.5]);
%------------------------------------------
%Bit Error rate Calculation
BER = sum(xor(data,estimatedBits))/length(data);
%Constellation Mapper at Transmitter side
subplot(4,2,6);
Q = zeros(1,length(nrzData)); %No Quadrature Component for BPSK
stem(nrzData,Q);
xlabel('Inphase Component');
ylabel('Quadrature Phase component');
title('BPSK Constellation at Transmitter');
axis([-1.5,1.5,-1,1]);
%constellation Mapper at receiver side
subplot(4,2,8);
Q = zeros(1,length(y)); %No Quadrature Component for BPSK
stem(y/max(y),Q);
xlabel('Inphase Component');
ylabel('Quadrature Phase component');
title(['BPSK Constellation at Receiver when AWGN Noise Variance =',num2str(noiseVariance)]);
axis([-1.5,1.5,-1,1]);