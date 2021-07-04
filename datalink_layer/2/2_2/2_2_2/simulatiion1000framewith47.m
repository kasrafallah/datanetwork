clc;
clear;
a = linspace(0,15,16);
a = de2bi(a);
for i = 1:length(a)
    code(i,:)= hamming4_7(a(i,:));
end

x = randi([0 1],1,100000);


bpskModulator = comm.BPSKModulator;
bpskDemodulator = comm.BPSKDemodulator;
tic
i = 1;
for snr = 1:0.1:10
    bit_counter = 0;
    counter = 1;
    temp = 0;
    while counter < length(x)
        temp_packet = [];
        for j = 0:4:999
            packet_data = x(j + counter:j + counter+3);
            a = hamming4_7(packet_data);
            temp_packet = [temp_packet a];
        end
        txData = temp_packet';   
        modSig = bpskModulator(txData)  ;      % Modulate
        rxSig = awgn(modSig,snr)  ;             % Pass through AWGN
        rxData = bpskDemodulator(rxSig) ;     % Demodulate
        temp_packet_received = [];
        for j = 1:7:length(rxData)
            packet_data = rxData(j :j +6)';
            a = encoding4_7(packet_data,code);
            temp_packet_received = [temp_packet_received a];
        end
        recieved = temp_packet_received;
        
        temp = temp+ sum(abs(recieved - x(counter:counter+999)));
        counter = counter + 1000;
    end
    toc
    error_rate(i) = temp/length(x);
    i = i + 1;
end
snr = 1:0.1:10;
figure;
semilogy(snr,error_rate)
xlabel('E/N(db)');
ylabel('BER');
grid on;grid minor;
title('BER of part 2.2.2');
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




