
clc;
clear;
n = 7;%# of codeword bits per block
k = 4;%# of message bits per block
A = [ 1 1 1;1 1 0;1 0 1;0 1 1 ];%Parity submatrix-Need binary(decimal combination of 7,6,5,3)            
G = [ eye(k) A ];%Generator matrix
H = [ A' eye(n-k) ];%Parity-check matrix
msg = [ 1 1 1 1 ]; %Message block vector-change to any 4 bit sequence
code = mod(msg*G,2);%Encode message


% CHANNEL ERROR(add one error to code)%
code(1)= ~code(1);
 %code(2)= ~code(2);
%code(3)= ~code(3);
%code(4)= ~code(4);%Pick one,comment out others
%code(5)= ~code(5);
%code(6)= ~code(6);
%code(7)= ~code(7);

syndrome_hamming_4_7_HD(code)

function msg_decoded = syndrome_hamming_4_7_HD(input)
n = 7;k = 4;       
A = [ 1 1 1;1 1 0;1 0 1;0 1 1 ];             
G = [ eye(k) A ];      %Generator matrix
H = [ A' eye(n-k) ];   %Parity-check matrix
syndrome = mod(input * H',2);
find = 0;   %Find position of the error in codeword (index)
for i = 1:n
    if ~find
        temp = zeros(1,n);
        temp(i) = 1;
        search = mod(temp * H',2);
        if search == syndrome
            find = 1;
            index = i;
        end
    end
end
correctedcode = input;
correctedcode(index) = mod(input(index)+1,2);
msg_decoded=correctedcode(1:4);
end

