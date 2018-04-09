clc;
clear all;
close all;

%% Initializing parameters
%L=input('Length Of OFDM Data = ');
L=48;   %Length Of OFDM Data
Ncp = L*0.0625;
%% Transmitter


% data generation
Tx_data=randi([0 15],L,Ncp);
%%%%%%%%%%%%%%%%%%% QAM modulation %%%%%%%%%%%%%%%%%%%%%
mod_data=qammod(Tx_data,16);
% Serial to Parallel
s2p=mod_data.';
% IFFT
am=ifft(s2p);
% Parallel to series
p2s=am.';
% Cyclic Prefixing
CP_part=p2s(:,end-Ncp+1:end); %Cyclic Prefix part to be appended.
cp=[CP_part p2s];

%%  Reciever

% Adding Noise using AWGN
SNRstart=0;
SNRincrement=2;
SNRend=30;
c=0;
r=zeros(size(SNRstart:SNRincrement:SNRend));
%r=zeros(size(0:5:30));
for snr=SNRstart:SNRincrement:SNRend
    c=c+1;
    noisy=awgn(cp,snr,'measured');
% Remove cyclic prefix part
    cpr=noisy(:,Ncp+1:Ncp+Ncp); %remove the Cyclic prefix
% series to parallel
    parallel=cpr.';
% FFT
    amdemod=fft(parallel);
% Parallel to serial
    rserial=amdemod.';
%%%%%%%%%%%%%%%%%%%% QAM demodulation %%%%%%%%%%%%%%%%%%%%%
    Umap=qamdemod(rserial,16);
% Calculating the Bit Error Rate
    [n, r(c)]=biterr(Tx_data,Umap);

end
snr=SNRstart:SNRincrement:SNRend;
%EbNo = 0:5:30;
%% Plotting BER vs SNR
%semilogy(snr,r,'-ok');
%grid;
%title('OFDM Bit Error Rate .VS. Signal To Noise Ratio');
%ylabel('BER');
%xlabel('SNR [dB]');


%% Plot the BER

figure;
semilogy(snr,r,'--or','linewidth',2);
%semilogy(EbNo,r,'--or','linewidth',2);
grid on;
title('OFDM BER vs SNR in Frequency selective Rayleigh fading channel');
xlabel('EbNo');
ylabel('BER');
