clc;
clear;

x = randi([0 1],1,100000);
a = linspace(0,15,16);
a = de2bi(a);
for i = 1:length(a)
    code(i,:)= hamming4_7(a(i,:));
end


bpskModulator = comm.BPSKModulator;
bpskDemodulator = comm.BPSKDemodulator;
tic
i = 1;
for snr = 1:0.1:10
    bit_counter = 0;
    counter = 1;
    temp = 0;
    while counter < length(x)-1000
        % Transmit a 50-symbol frame
        packet_data = x(counter:counter+998);
        parity = mod(sum(packet_data),2);
        txData = [packet_data parity]';
        temp_packet = [];
        for j = 1:4:length(txData)
            a = hamming4_7(txData(j:j+3)');
            temp_packet = [temp_packet a];    
        end
        txData1 = temp_packet';
        bit_counter = bit_counter + 250 *7;
        modSig = bpskModulator(txData1);        % Modulate
        rxSig = awgn(modSig,snr);                % Pass through AWGN
        rxData = bpskDemodulator(rxSig);      % Demodulate
        temp_packet = [];
        for j = 1:7:length(rxData)
            a = encoding4_7(rxData(j:j+6)',code);
            temp_packet = [temp_packet a];    
        end
        rxData = temp_packet';
        
        if mod(sum(rxData(1:999)),2) ~= rxData(1000)
            counter = counter;
        elseif mod(sum(rxData(1:999)),2) == rxData(1000)
            counter = counter + 999;
            temp = temp+ sum(abs(txData - rxData));
        end
    end
    error_rate(i) = temp/length(x);
    total_bit(i) = bit_counter;
    i = i + 1;
toc
end
snr = 1:0.1:10;
figure;
plot(snr,total_bit/100000)
xlabel('E/N(db)');
ylabel('No. of bit trasmit/No. of data bit');
grid on;grid minor;
title('total bit transmit of part 2.3');
figure;
semilogy(snr,error_rate)
xlabel('E/N(db)');
ylabel('BER');
grid on;grid minor;
title('BER of part 2.3');


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