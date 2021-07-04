clc;
clear;
packetsize = 256;
packetnumbaer = 1024;
x = randi([0 1],1,packetnumbaer * packetsize);
pattern = [0,1,1,1,1,1,1,0];

i = 1;

out = [];
%transmiter
while i < length(x)
    temp = x(i:i + packetsize-1);
    
    k =0;
    temp2 = [];
    for j = 1:length(temp)
        if temp(j) == 1
            k = k + 1;
            if k == 5
                temp2 = [temp2 ,temp(j) ,0];
                k = 0;
            else
                temp2 = [temp2 temp(j)];
            end   
        end
        if temp(j) == 0
            k = 0;
            temp2 = [temp2 temp(j)];
        end       
    end

    out = [out pattern temp2];
    i = i + packetsize;
end
out = [out pattern];


%reciever

temp = conv(out,pattern,'full');
result = find(temp==6);
data=[];
for i = 1: length(result) - 1
    temppacket = out(result(i)+1:result(i+1)-8);
    tempconv = conv(temppacket,[1,1,1,1,1]);
    result2 = find(tempconv ==5);
    temppacket(result2+1) = [];
    data = [data temppacket];
end
%x
%data
%sum(data - x)
xor(data,x);
if data == x
    disp('done')
end



    
    
    
    
    
    
    
    
    