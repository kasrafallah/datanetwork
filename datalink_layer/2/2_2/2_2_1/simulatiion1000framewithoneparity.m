clc;
clear;

x = randi([0 1],1,100000);


bpskModulator = comm.BPSKModulator;
bpskDemodulator = comm.BPSKDemodulator;

i = 1;
for snr = 1:0.1:10
    bit_counter = 0;
    counter = 1;
    temp = 0;
    while counter < length(x)

        packet_data = x(counter:counter+999);
        parity = mod(sum(packet_data),2);
        txData = [packet_data parity]';
        bit_counter = bit_counter + 1001;
        modSig = bpskModulator(txData);        % Modulate
        rxSig = awgn(modSig,snr);                % Pass through AWGN
        rxData = bpskDemodulator(rxSig);      % Demodulate
        if mod(sum(rxData(1:1000)),2) ~= rxData(1001)
            counter = counter;
        elseif mod(sum(rxData(1:1000)),2) == rxData(1001)
            counter = counter + 1000;
            temp = temp+ sum(abs(txData - rxData));
        end
    end
    error_rate(i) = temp/length(x);
    total_bit(i) = bit_counter;
    i = i + 1;

end
snr = 1:0.1:10;
figure;
plot(snr,total_bit/100000)
xlabel('E/N(db)');
ylabel('No. of bit trasmit/No. of data bit');
grid on;grid minor;
title('total bit transmit of part 2.1');
figure;
semilogy(snr,error_rate)
xlabel('E/N(db)');
ylabel('BER');
grid on;grid minor;
title('BER of part 2.1');
