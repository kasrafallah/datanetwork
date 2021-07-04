clc;
clear;
close all;
x = randi([0 1],1,100000);
a = linspace(0,15,16);
a = de2bi(a);
for i = 1:length(a)
    code(i,:)= hamming4_7(a(i,:));
end

bpskModulator = comm.BPSKModulator;
bpskDemodulator = comm.BPSKDemodulator;
tic

for s = 1 :1:10
    i = 1;
for snr = 1:0.1:10
    bit_counter = 0;
    counter = 1;
    temp = 0;
    while counter < length(x)
        % Transmit a 50-symbol frame
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
    error_rate1(s,i) = temp/length(x)*100;
    total_bit1(s,i) = bit_counter;
    i = i + 1;

end
toc
end
error_rate1 = sum(error_rate1)/10;
total_bit1 = sum(total_bit1)/10;
%%
bpskModulator = comm.BPSKModulator;
bpskDemodulator = comm.BPSKDemodulator;

tic
for s = 1 :1:10
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
    error_rate2(s,i) = temp/length(x)*100;
    i = i + 1;
end
end
error_rate2 = sum(error_rate2)/10;



bpskModulator = comm.BPSKModulator;
bpskDemodulator = comm.BPSKDemodulator;
tic
for s = 1 :1:10
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
    error_rate3(s,i) = temp/length(x)*100;
    total_bit3(s,i) = bit_counter;
    i = i + 1;
toc
end
tic
end
error_rate3 = sum(error_rate3)/10;
total_bit3 = sum(total_bit3)/10;
%%
for s = 1 :1:10
i = 1
for snr = 1:0.1:10
    bit_counter = 0;
    counter = 1;
    temp = 0;
    while counter < length(x)
       
        packet_data = x(counter:counter+999);
       
        txData = [packet_data ]';
       
        bit_counter = bit_counter + 1000;
        modSig = bpskModulator(txData);        % Modulate
        rxSig = awgn(modSig,snr);                % Pass through AWGN
        rxData = bpskDemodulator(rxSig);      % Demodulate
        temp = temp+ sum(abs(txData - rxData));
        counter = counter +1000;
    end
    error_rate4(s,i) = temp/length(x)*100;
    total_bit4(s,i) = bit_counter;
    i = i + 1;
a = toc
end
end
error_rate4 = sum(error_rate4)/10;

snr = 1:0.1:10;
figure;
semilogy(snr,error_rate1)
hold on;
semilogy(snr,error_rate2)
hold on;
semilogy(snr,error_rate3)
hold on;
semilogy(snr,error_rate4)
title('BER of all parts');
xlabel('E/N(db)');
ylabel('BER(%)');
grid on;grid minor;
legend('2.1','2.2','2.3','uncoded')
figure;

plot(snr,total_bit1/100000)
hold on;
plot(snr,1000/4*7*ones(1,length(snr))*100/100000);
hold on;
plot(snr,total_bit3/100000);
title('total bit transmit of all parts');
xlabel('E/N(db)');
ylabel('No. of bit trasmit/No. of data bit');
grid on;grid minor;
legend('2.1','2.2','2.3')







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