clc;
clear;
packetsize = 256;
packetnumbaer = 1024;
x = randi([0 1],1,packetnumbaer * packetsize);
pattern = [0,1,1,1,1,1,1,1,1,1,0];

i = 1;
%trasmiter
out = [];
while i < length(x)
    temp = x(i:i + packetsize-1);
    
    temp3 = [];
    for j = 1:4:length(temp)
        
      a = temp(j:j+3);
      temp2 = coder(a);
      temp3 = [temp3 , temp2];
   
    end
    length(temp3);
    out = [out pattern temp3];
    i = i + packetsize;
end
out = [out pattern];


%reciever

temp = conv(out,pattern,'full');
result = find(temp==9);
data=[];
for i = 1: length(result) - 1
    temppacket = out(result(i)+1:result(i+1)-11);
%     a = result(i)+1
%     b = result(i+1)-11
%     c = length(temppacket)
    temp4 = [];
    for j = 1:5:length(temppacket)
        a = temppacket(j:j+4);
        temp3 = decoder(a);
        temp4 = [temp4 temp3];
    end
%temp4
    data = [data temp4];
end
%x
%data
%sum(data - x)
xor(data,x);
if data == x
    disp('done')
end


function out = coder(a)
if a == [0,0,0,0]
    temp2 = [1,1,1,1,0];
elseif a == [0,0,0,1]
    temp2 = [0,1,0,0,1];
elseif a == [0,0,1,0]
    temp2 = [1,0,1,0,0];
elseif a == [0,0,1,1]
    temp2 = [1,0,1,0,1];
elseif a == [0,1,0,0]
    temp2 = [0,1,0,1,0];    
elseif a == [0,1,0,1]
    temp2 = [0,1,0,1,1];
elseif a == [0,1,1,0]
    temp2 = [0,1,1,1,0];
elseif a == [0,1,1,1]
    temp2 = [0,1,1,1,1];
elseif a == [1,0,0,0]
    temp2 = [1,0,0,1,0];
elseif a == [1,0,0,1]
    temp2 = [1,0,0,1,1];
elseif a == [1,0,1,0]
    temp2 = [1,0,1,1,0];
elseif a == [1,0,1,1]
    temp2 = [1,0,1,1,1];
elseif a == [1,1,0,0]
    temp2 = [1,1,0,1,0];
elseif a == [1,1,0,1]
    temp2 = [1,1,0,1,1];
elseif a == [1,1,1,0]
    temp2 = [1,1,1,0,0];
elseif a == [1,1,1,1]
    temp2 = [1,1,1,0,1];
end  
out = temp2;
end
function out = decoder(a)
if a == [1,1,1,1,0]
    temp2 = [0,0,0,0];
elseif a == [0,1,0,0,1]
    temp2 = [0,0,0,1];
elseif a == [1,0,1,0,0]
    temp2 = [0,0,1,0];
elseif a == [1,0,1,0,1]
    temp2 = [0,0,1,1];
elseif a == [0,1,0,1,0]
    temp2 = [0,1,0,0];    
elseif a == [0,1,0,1,1]
    temp2 = [0,1,0,1];
elseif a == [0,1,1,1,0]
    temp2 = [0,1,1,0];
elseif a == [0,1,1,1,1]
    temp2 = [0,1,1,1];
elseif a == [1,0,0,1,0]
    temp2 = [1,0,0,0];
elseif a == [1,0,0,1,1]
    temp2 = [1,0,0,1];
elseif a == [1,0,1,1,0]
    temp2 = [1,0,1,0];
elseif a == [1,0,1,1,1]
    temp2 = [1,0,1,1];
elseif a == [1,1,0,1,0]
    temp2 = [1,1,0,0];
elseif a == [1,1,0,1,1]
    temp2 = [1,1,0,1];
elseif a == [1,1,1,0,0]
    temp2 = [1,1,1,0];
elseif a == [1,1,1,0,1]
    temp2 = [1,1,1,1];
end  
out = temp2;
end









