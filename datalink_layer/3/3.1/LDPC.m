a = linspace(0,15,16);
a = de2bi(a);
for i = 1:length(a)
    code(i,:)= hamming4_7(a(i,:));
end
M = 4; % Modulation order (QPSK)
snr = [0:0.25:5];
numFrames = 10;
ldpcEncoder = comm.LDPCEncoder;
ldpcDecoder = comm.LDPCDecoder;
pskMod = comm.PSKModulator(M,'BitInput',true);
pskDemod = comm.PSKDemodulator(M,'BitOutput',true,...
    'DecisionMethod','Approximate log-likelihood ratio');
pskuDemod = comm.PSKDemodulator(M,'BitOutput',true,...
    'DecisionMethod','Hard decision');
errRate = zeros(1,length(snr));
uncErrRate = zeros(1,length(snr));
tic

for ii = 1:length(snr)
    ttlErr = 0;
    ttlErrUnc = 0;
    pskDemod.Variance = 1/10^(snr(ii)/10); % Set variance using current SNR
    for counter = 1:numFrames
        data = logical(randi([0 1],32400,1));
        data_channel = [];
        for j = 1:4:length(data)
            data_channel = [data_channel hamming4_7(data(j:j+3)')];
        end
        data_channel = data_channel';
        mod_uncSig = pskMod(data_channel);
        rx_uncSig = awgn(mod_uncSig,snr(ii),'measured');
        demod_uncSig = pskuDemod(rx_uncSig);
        data_channel = [];
        for j = 1:7:length(demod_uncSig)
            data_channel = [data_channel encoding4_7(demod_uncSig(j:j+6)',code)];
        end
        
        data_channel = data_channel';
        numErrUnc = biterr(data,data_channel);
        ttlErrUnc = ttlErrUnc + numErrUnc;
        
    end
    ttlBits = numFrames*32400;
    uncErrRate(ii) = ttlErrUnc/ttlBits
    errRate(ii) = ttlErr/ttlBits;
    toc
end



%%
M = 4; % Modulation order (QPSK)
;
numFrames = 10;
ldpcEncoder = comm.LDPCEncoder;
ldpcDecoder = comm.LDPCDecoder;
pskMod = comm.PSKModulator(M,'BitInput',true);
pskDemod = comm.PSKDemodulator(M,'BitOutput',true,...
    'DecisionMethod','Approximate log-likelihood ratio');
pskuDemod = comm.PSKDemodulator(M,'BitOutput',true,...
    'DecisionMethod','Hard decision');
errRate = zeros(1,length(snr));
tic
for ii = 1:length(snr)
    ttlErr = 0;
    ttlErrUnc = 0;
    pskDemod.Variance = 1/10^(snr(ii)/10); % Set variance using current SNR
    for counter = 1:numFrames
        data = logical(randi([0 1],32400,1));
        % Transmit and receive LDPC coded signal data
        encData = ldpcEncoder(data);
        modSig = pskMod(encData);
        rxSig = awgn(modSig,snr(ii),'measured');
        demodSig = pskDemod(rxSig);
        rxBits = ldpcDecoder(demodSig);
        numErr = biterr(data,rxBits);
        ttlErr = ttlErr + numErr;
    end
    ttlBits = numFrames*length(rxBits);
    errRate(ii) = ttlErr/ttlBits
    toc
end

%%
figure;
plot(snr,uncErrRate,snr,errRate)
legend('Hamming4to7', 'LDPC coded')
xlabel('SNR (dB)')
ylabel('BER')
grid on;grid minor;


%%
function out = hamming4_7(a)
out = [a, mod((a(1)+a(2)+a(3)),2),...
    mod((a(2)+a(3)+a(4)),2),...
    mod((a(1)+a(2)+a(4)),2)];

end

function out = encoding4_7(input,code)


%Hard decision
input_H = (1- 2 *input <0);
distance = sum(abs(ones(16,1)*input_H - code),2);
[min_func, index_h] = min(distance);
massage_recieved_h = code(index_h,1:4);
    
%soft decision
input_s = 1- 2 *input ;
[max_func, index_s] = max(input_s*(1-2*code)');
massage_recieved_s = code(index_s,1:4);

out = massage_recieved_h;
end
