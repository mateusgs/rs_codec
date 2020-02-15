
% RSCodingConfigExample Initialization script for Reed-Solomon doc examples.
%
%   This MATLAB file is in support of various doc examples and may be removed in
%   a future release.
%
%   Initialize modulator, demodulator, AWGNChannel, and error rate
%   measurement System objects. Define simulation value for uncoded Eb/No
%   ratio, and set simulation stop criteria for the RS coding examples with
%   erasures, punctures, and shortening.

%   Copyright 2010-2014 The MathWorks, Inc.

% If initialization is called by the example, then set a single uncoded
% Eb/No value, and set the simulation stop criteria.
if ~exist('initFlagRSDemo', 'var') || initFlagRSDemo
  EbNoUncoded = 15; % dB
    
  % Set the simulation stop criteria by defining the target number of errors
  % and maximum number of transmissions.
  %targetErrors = 500;
  %maxNumTransmissions = 50e4;  
  targetErrors = 10000000;
  maxNumTransmissions = 100000;  
end
plotS = [];
ber =  zeros(6,16);
p = 1;
n = 1;
mk = ['-*', '-x', '-o', '-v', '-^']
%% Rectangular 64-QAM Modulation
% Create a rectangular 64-QAM modulator System object. Set the SymbolMapping
% to 'Gray' for Gray coding and set the BitInput property to false to
% specify that the modulator's input is integer symbols.

M = 16; % Modulation order
hMod  = comm.PAMModulator(M);
hDemod = comm.PAMDemodulator(M);
%hMod = comm.RectangularQAMModulator(M, 'SymbolMapping', 'Gray',...
%  'BitInput', false);

% Create a rectangular 64-QAM demodulator System object with same settings
% as the modulator. Set the BitOutput property to false so that the
% demodulator outputs integer symbols.
%hDemod = comm.RectangularQAMDemodulator(M, 'SymbolMapping', 'Gray',...
%  'BitOutput', false);

%% AWGN Channel
% Create an additive white Gaussian noise (AWGN) channel System object. Set
% the NoiseMethod property to 'Signal to noise ratio (Eb/No)' to specify the
% noise level using the energy per bit to noise power spectral density ratio
% (Eb/No) in dB. 
hChan = comm.AWGNChannel('NoiseMethod', 'Signal to noise ratio (Eb/No)');

% We assume no upsampling so the number of samples per symbol is 1. The
% signal power for rectangular 64-QAM is 42 Watts, so we set the SignalPower
% property of the channel to this value.
hChan.SamplesPerSymbol = 1;
hChan.SignalPower = 42; 

% The number of bits per symbol is equal to log2(M). We need to set the
% BitsPerSymbol property of the AWGN channel System object so that it knows
% how to distribute noise evenly across the symbol samples.
hChan.BitsPerSymbol = log2(M);

%% Error rate measurement
% Create two error rate measurement System objects, one to measure the
% channel bit error rate (BER), and the other to measure the coded BER.
% Since the inputs and outputs of the modulator and demodulator are integer
% symbols, and we want to measure bit error rates, we also need to create
% integer to bit converters.

% Error rate measurement System object for channel BER
hChanBERCalc = comm.ErrorRate; 
% Error rate measurement System object for coded BER
hCodedBERCalc = comm.ErrorRate;
% Integer to bit converters. Set the BitsPerInteger property to log2(M)=6 to
% convert integers to 6-bit words
hIntToBit1 = comm.IntegerToBit('BitsPerInteger', log2(M));
hIntToBit2 = comm.IntegerToBit('BitsPerInteger', log2(M));

% We also create a cumulative sum System object to log the number of errors
% corrected by the RS decoder.
hCumSum = dsp.CumulativeSum;

%%
EbNodB=0:1:16;
EbNo=10.^(EbNodB/10);
k=6;
M=64;
[ber, ser] = berawgn(EbNodB,'pam',M);
[ber16, ser16] = berawgn(EbNodB,'pam',16);
%semilogy(EbNodB,ber16, marker(n), 'DisplayName', 'cu')
%semilogy(EbNodB,ber16, marker(n))
%plotS(p) = semilogy(EbNodB,ber16, mk(n))
ber(p,:) = ber16';
p = p + 1;
n = n+1

grid on; drawnow;
hold on;

%%
BitErrorRate = zeros(17,1);
%K_vec = [7,1];  % Message length
%K_vec = [11, 7, 4, 2];
for EbNoUncoded = 0:16
%EbNoUncoded = 15;
%EbNoCoded = EbNoUncoded + 10*log10(K/N);
%hChan.EbNo = EbNoUncoded + 10*log10(K);
hChan.EbNo = EbNoUncoded;
%hChan.EbNo = 1000;

chanErrorStats = zeros(3,1);
codedErrorStats = zeros(3,1);
correctedErrors = 0;
reset(hCodedBERCalc);
reset(hCodedBERCalc);
%targetErrors = 5000;
%maxNumTransmissions = 50000000;
%while (codedErrorStats(2) < targetErrors) && ...
%(codedErrorStats(3) < maxNumTransmissions)
N = 15
while (codedErrorStats(3) < maxNumTransmissions)
  data = randi([0 N],N,1);
  %encData = step(rsEncoder, real(data));
  modData = step(hMod, real(data));
  hChan.SignalPower = (real(modData)' * real(modData))/ length(real(modData));
  chanOutput = step (hChan, real(modData));
  demodData = step(hDemod, real(chanOutput));
  %decData = step(rsDecoder, real(demodData));
  encDataBit1 = step(hIntToBit1, data);
  demodDataBit1 = step(hIntToBit2, demodData);
  %chanErrorStats(:,1) = ...
  %  step(hChanBERCalc, encDataBit1,demodDataBit1);
  % Convert integers to bits and compute the coded BER.
  % codedErrorStats(:,1) = ...
  %  codedBERCalc(intToBit2(data),intToBit2(estData));
  %dataBit2 = step(hIntToBit2, data);
  %estDataBit2 = step(hIntToBit2, estData);
  dataBit2 = step(hIntToBit2, data);
  estDataBit2 = step(hIntToBit2, demodData);
  codedErrorStats(:,1) = ...
    step(hCodedBERCalc, dataBit2, estDataBit2);
end

codedBitErrorRate = codedErrorStats(1);
totalCorrectedErrors = correctedErrors;
%EbNoUncoded
EbNoUncoded;
BitErrorRate(EbNoUncoded + 1) = codedBitErrorRate;
EbNodB=0:1:16;
%plotS(p) = semilogy(EbNodB,BitErrorRate, mk(n))
 
end

ber(p,:) = BitErrorRate';
p = p + 1;

%%
plot = []
N = 15;  % Codeword length
BitErrorRate = zeros(17,1);
%K_vec = [7,1];  % Message length
%K_vec = [11, 7, 4, 2];
for K = [11, 7, 4, 2]
%BitInput = false means integers for inputs
rsEncoder = comm.RSEncoder(N,K, 'BitInput', false);
rsDecoder = comm.RSDecoder(N,K, 'BitInput', false);

%RS Decoder outputs number of corrected errors (-1 is returned when decoder
%was not able to correct a given code word)
rsDecoder.NumCorrectedErrorsOutputPort = true;
for EbNoUncoded = 0:16
%EbNoUncoded = 15;
%EbNoCoded = EbNoUncoded + 10*log10(K/N);
%hChan.EbNo = EbNoUncoded + 10*log10(K);
hChan.EbNo = EbNoUncoded;
%hChan.EbNo = 1000;

chanErrorStats = zeros(3,1);
codedErrorStats = zeros(3,1);
correctedErrors = 0;
reset(hCodedBERCalc);
reset(hCodedBERCalc);
%targetErrors = 5000;
%maxNumTransmissions = 50000000;
%while (codedErrorStats(2) < targetErrors) && ...
%(codedErrorStats(3) < maxNumTransmissions)
while (codedErrorStats(3) < maxNumTransmissions)
  data = randi([0 N],K,1);
  encData = step(rsEncoder, real(data));
  modData = step(hMod, real(encData));
  hChan.SignalPower = (real(modData)' * real(modData))/ length(real(modData));
  chanOutput = step (hChan, real(modData));
  demodData = step(hDemod, real(chanOutput));
  decData = step(rsDecoder, real(demodData));
  encDataBit1 = step(hIntToBit1, data);
  demodDataBit1 = step(hIntToBit2, demodData);
  %chanErrorStats(:,1) = ...
  %  step(hChanBERCalc, encDataBit1,demodDataBit1);
  % Convert integers to bits and compute the coded BER.
  % codedErrorStats(:,1) = ...
  %  codedBERCalc(intToBit2(data),intToBit2(estData));
  %dataBit2 = step(hIntToBit2, data);
  %estDataBit2 = step(hIntToBit2, estData);
  dataBit2 = step(hIntToBit2, data);
  estDataBit2 = step(hIntToBit2, decData);
  codedErrorStats(:,1) = ...
    step(hCodedBERCalc, dataBit2, estDataBit2);
end

codedBitErrorRate = codedErrorStats(1);
totalCorrectedErrors = correctedErrors;
%EbNoUncoded
EbNoUncoded;
BitErrorRate(EbNoUncoded + 1) = codedBitErrorRate;
end

EbNodB=0:1:16;
ber(p,:) = BitErrorRate';
%plotS(p) = semilogy(EbNodB,BitErrorRate, mk(n:n+1))
n = n+2;
p = p + 1;
end
%%
semilogy(EbNodB,ber(2,:), mk(1:2), 'Color', 'k')
xlabel('E_b/N_0 (dB)'); ylabel('Bit Error Rate');
hold on;
%semilogy(EbNodB,ber(2,:), mk(2), 'Color', 'k')
semilogy(EbNodB,ber(3,:), '-diamond', 'Color', 'k')
semilogy(EbNodB,ber(4,:), mk(5:6), 'Color', 'k')
semilogy(EbNodB,ber(5,:), mk(7:8), 'Color', 'k')
semilogy(EbNodB,ber(6,:), mk(9:10), 'Color', 'k')
title('E_b/N_0 (dB) vs BER for PAM-16 with RS codecs over AWGN channels')
%legend('a', 'b', 'c')
legend('no RS', 'RS(15,11)', 'RS(15,7)', 'RS(15,4)', 'RS(15,2)' )
