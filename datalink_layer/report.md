
## 1. Framing
### One of the main issues that we have in receivers is that when our data doesn’t have enough transitions,the receiver won’t receive data properly. As you have learned, two # approaches for solving this problem arebit-stuffing and coding violation. In this section, we will examine these two solutions.

## 1.1 Bit-stuffing
###  Suppose you get some random packets from the upper layer with the same length. Write a Matlab code to frame each packet using bit-stuffing. Use the ‘01111110’ pattern to frame packets. Finally, send the frames to a serial link. At the receiver, you must be able to receive data and extract the packets properly.Report the result of exclusive or (XOR) operation between each extracted packet and corresponding sent packet.

> 
> To execute the bit stuffing protocol for framing in the data link layer, we must first form the packets and look for "11111" in it, which I did with a counter, then we have to add a zero after each one and Finally, place the packages between the flags.
To detect data in the receiver, I convolved the entire input of the receiver in the given flag pattern, and in this way, I found the location of the packets, which are between the flags. Finally, by finding the "111110" sequences and converting them to "11111", I detected the data.
 To show the equality of the data that transmitted and detected, I calculated the XOR of them that obviously equal to zero.The MATLAB code is shown below:
{: .gitlab-purple}

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

### 1.2 4B/5B coding
#### Assume the previous part, but this time you should implement the framing function using 4B/5B coding. At the receiver, you must be able to decode data and extract packets properly. Report the result of exclusive or (XOR) operation between each extracted packet and corresponding sent packet.


> #### 
> To write this part, I first wrote the two encoder and decoder functions for 4-bit / 5-bit 
For framing, I separated and coded 4 to 4 pieces of data and placed every 1000 bits of data between flags to be specified.
To decode, I first cannulated the entire input of the receiver in the flag pattern and used it to specify the data packets, then I detect the data using the decoder function.
The MATLAB code is shown below:


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
    temp4 = [];
    for j = 1:5:length(temppacket)
        a = temppacket(j:j+4);
        temp3 = decoder(a);
        temp4 = [temp4 temp3];
    end
    data = [data temp4];
    end

### 2.1 Hamming codes

#### 2.1.1  By giving an example, describe the encoding technique of linear block codes. Introduce the role of parity check and generator matrices.


>
>Recall that a linear block code takes k-bit message blocks and converts each such block into n-bit coded blocks. The rate of the code is k/n. The conversion in a linear block code involves only linear operations over the message bits to produce code words.
one of the main examples of a linear block code system is hamming code, as we have in this assignment Hamming (7,4) is one of the most popular codings of this type.
in hamming code, we have a concept named hamming distance that shows the power of hamming code to correct and detect the errors
For example, consider the code consisting of two code words "000" and "111". The hamming distance between these two words is 3, and therefore it is k=2 error detecting. This means that if one bit is flipped or two bits are flipped, the error can be detected
