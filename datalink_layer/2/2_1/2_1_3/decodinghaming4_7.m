clc;
clear;
close all;




%finding code words
a = linspace(0,15,16);
a = de2bi(a);
for i = 1:length(a)
    code(i,:)= hamming4_7(a(i,:));
end

input = [1     1     0     1     0     0     1];
encoding4_7(input,code)


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



function out = hamming4_7(a)
out = [a, mod((a(1)+a(2)+a(3)),2),...
    mod((a(2)+a(3)+a(4)),2),...
    mod((a(1)+a(2)+a(4)),2)];

end