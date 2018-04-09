% Demonstration of QPSK Modulation and Demodulation
clear; %clear all stored variables
N=100; %number of data bits
noiseVariance = 0.1; %Noise variance of AWGN channel
Rb=1e3; %bit rate
amplitude=1; % Amplitude of NRZ data
data=randn(1,N)>=0; %Generate uniformly distributed random data
oddBits = data(1:2:end);
evenBits= data(2:2:end);
[evenTime,evenNrzData,Fs]=NRZ_Encoder(evenBits,Rb,amplitude,'Polar');
[oddTime,oddNrzData]=NRZ_Encoder(oddBits,Rb,amplitude,'Polar');
Fc=2*Rb;
inPhaseOsc = 1/sqrt(2)*cos(2*pi*Fc*evenTime);
quadPhaseOsc = 1/sqrt(2)*sin(2*pi*Fc*oddTime);
qpskModulated = oddNrzData.*quadPhaseOsc + evenNrzData.*inPhaseOsc;
Tb=1/Rb;
subplot(3,2,1);
stem(data);
xlabel('Samples');
ylabel('Amplitude');
title('Input Binary Data');
axis([0,N,-0.5,1.5]);
subplot(3,2,3);
plotHandle=plot(qpskModulated);
xlabel('Samples');
ylabel('Amplitude');
title('QPSK modulated Data');
xlimits = xlim;
ylimits = ylim;
axis([xlimits,ylimits(1)-0.5,ylimits(2)+0.5]) ;
grid on;
%-------------------------------------------
%Adding Channel Noise
%-------------------------------------------
noise = sqrt(noiseVariance)*randn(1,length(qpskModulated));
received = qpskModulated + noise;
subplot(3,2,5);
plot(received);
xlabel('Time');
ylabel('Amplitude');
title('QPSK Modulated Data with AWGN noise');
%-------------------------------------------
%QPSK Receiver
%-------------------------------------------
%Multiplying the received signal with reference Oscillator
iSignal = received.*inPhaseOsc;
qSignal = received.*quadPhaseOsc;
%Integrator
integrationBase = 0:1/Fs:Tb-1/Fs;
for i = 0:(length(iSignal)/(Tb*Fs))-1,
inPhaseComponent(i+1)=trapz(integrationBase,iSignal(int32(i*Tb*Fs+1):int32((i+1)*Tb*Fs)));
end
for i = 0:(length(qSignal)/(Tb*Fs))-1,
quadraturePhaseComponent(i+1)=trapz(integrationBase,qSignal(int32(i*Tb*Fs+1):int32((i+1)*Tb*Fs)));
end
%Threshold Comparator
estimatedInphaseBits=(inPhaseComponent>=0);
estimatedQuadphaseBits=(quadraturePhaseComponent>=0);
finalOutput=reshape([estimatedQuadphaseBits;estimatedInphaseBits],1,[]);
BER = sum(xor(finalOutput,data))/length(data);
subplot(3,2,2);
stem(finalOutput);
xlabel('Samples');
ylabel('Amplitude');
title('Detected Binary Data after QPSK demodulation');
axis([0,N,-0.5,1.5]);
%Constellation Mapping at transmitter and receiver
%constellation Mapper at Transmitter side
subplot(3,2,4);
plot(evenNrzData,oddNrzData,'ro');
xlabel('Inphase Component');
ylabel('Quadrature Phase component');
title('QPSK Constellation at Transmitter');
axis([-1.5,1.5,-1.5,1.5]);
h=line([0 0],[-1.5 1.5]);
set(h,'Color',[0,0,0])
h=line([-1.5 1.5],[0 0]);
set(h,'Color',[0,0,0])
%constellation Mapper at receiver side
subplot(3,2,6);
%plot(inPhaseComponent/max(inPhaseComponent),quadraturePhaseComponent/max(quadraturePhaseComponent),'plot(2*estimatedInphaseBits-1,2*estimatedQuadphaseBits-1,'ro');
xlabel('Inphase Component');
ylabel('Quadrature Phase component');
title(['QPSK Constellation at Receiver when AWGN Noise Variance =',num2str(noiseVariance)]);
axis([-1.5,1.5,-1.5,1.5]);
h=line([0 0],[-1.5 1.5]);
set(h,'Color',[0,0,0]);
h=line([-1.5 1.5],[0 0]);
set(h,'Color',[0,0,0]);