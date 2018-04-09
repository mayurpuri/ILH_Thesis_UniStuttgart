%Simulation of OFDM system in an AWGN environment Follows IEEE 802.11 specification
clear; clc;
%--------Simulation parameters----------------
nSym=10^4; %Number of OFDM Symbols to transmit
%EbN0dB = -20:2:8; % bit to noise ratio
EbN0dB = 0:2:30;
%---------------------------------------------
%--------OFDM Parameters - Given in IEEE Spec--
N=64; %FFT size or total number of subcarriers (used + unused) 64
Nsd = 48; %Number of data subcarriers 48
Nsp = 4 ; %Number of pilot subcarriers 4
ofdmBW = 20 * 10^6 ; % OFDM bandwidth
%----------------------------------------------
%--------Derived Parameters--------------------
deltaF = ofdmBW/N; %=20 MHz/64 = 0.3125 MHz
Tfft = 1/deltaF; % IFFT/FFT period = 3.2us
Tgi = Tfft/4;%Guard interval duration - duration of cyclic prefix
Tsignal = Tgi+Tfft; %duration of BPSK-OFDM symbol
Ncp = N*Tgi/Tfft; %Number of symbols allocated to cyclic prefix
Nst = Nsd + Nsp; %Number of total used subcarriers
nBitsPerSym=Nst; %For BPSK the number of Bits per Symbol is same as num of subcarriers
%----------------------------------------------
EsN0dB = EbN0dB + 10*log10(Nst/N) + 10*log10(N/(Ncp+N)); % converting to symbol to noise ratio
errors= zeros(1,length(EsN0dB));
theoreticalBER = zeros(1,length(EsN0dB));
%Monte Carlo Simulation
for i=1:length(EsN0dB),
for j=1:nSym
%-----------------Transmitter--------------------
s=2*round(rand(1,Nst))-1; %Generating Random Data with BPSK modulation
%IFFT block
%Assigning subcarriers from 1 to 26 (mapped to 1-26 of IFFT input)
%and -26 to -1 (mapped to 38 to 63 of IFFT input); Nulls from 27 to 37
%and at 0 position
X_Freq=[zeros(1,1) s(1:Nst/2) zeros(1,11) s(Nst/2+1:end)];
% Pretending the data to be in frequency domain and converting to time domain
x_Time=N/sqrt(Nst)*ifft(X_Freq);
%Adding Cyclic Prefix
ofdm_signal=[x_Time(N-Ncp+1:N) x_Time];
%--------------Channel Modeling ----------------
noise=1/sqrt(2)*(randn(1,length(ofdm_signal))+1i*randn(1,length(ofdm_signal)));
r= sqrt((N+Ncp)/N)*ofdm_signal + 10^(-EsN0dB(i)/20)*noise;
%-----------------Receiver----------------------
%Removing cyclic prefix
r_Parallel=r(Ncp+1:(N+Ncp));
%FFT Block
r_Time=sqrt(Nst)/N*(fft(r_Parallel));
%Extracting the data carriers from the FFT output
R_Freq=r_Time([(2:Nst/2+1) (Nst/2+13:Nst+12)]);
%BPSK demodulation / Constellation Demapper.Force +ve value --> 1, -ve value --> -1
R_Freq(R_Freq>0) = +1;
R_Freq(R_Freq<0) = -1;
s_cap=R_Freq;
numErrors = sum(abs(s_cap-s)/2); %Count number of errors
%Accumulate bit errors for all symbols transmitted
errors(i)=errors(i)+numErrors;
end
theoreticalBER(i)=(1/2)*erfc(sqrt(10.^(EbN0dB(i)/10))); %Same as BER for BPSK over AWGN
end
simulatedBER = errors/(nSym*Nst);
%plot(EbN0dB,log10(simulatedBER),'r-o');
%hold on;
%plot(EbN0dB,log10(theoreticalBER),'k*');
%grid on;
%title('BER Vs EbNodB for OFDM with BPSK modulation over AWGN');
%xlabel('Eb/N0 (dB)');ylabel('BER');legend('simulated','theoretical');

%% Plot the BER

figure;
semilogy(EbN0dB,simulatedBER,'--or','linewidth',2);
grid on;
title('OFDM BER vs SNR in Frequency selective AWGN channel');
xlabel('EbNo');
ylabel('BER');