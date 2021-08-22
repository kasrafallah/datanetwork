

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

<p align="center">
<image align="center" src = "images/one.png" width="600">
</p>

#### 2.1.2 Hamming codes are a class of linear block codes with n = 2m − 1 and k = 2m − m − 1 for some m > 3. What is the Hamming distance in Hamming codes? Write a MATLAB function to implement encoding of a (7,4) Hamming code.
 
>
>To write 4 to 7 Hamming coding function, we only need to calculate the added 3 bits in the function, which is done as shown in the following MATLAB file:

    function out = hamming4_7(a)
    out = [a, mod((a(1)+a(2)+a(3)),2),...
        mod((a(2)+a(3)+a(4)),2),...
        mod((a(1)+a(2)+a(4)),2)];

    end
 
 
> To test the function, we test it for one input, for example, consider input [1,1,0,1] and get the following result, which is as expected.
 
 #### 2.1.3 Write a MATLAB function to implement decoding of a (7,4) Hamming code utilizing standard array technique. This technique is explained in part 13.2.1 of [1].
 
> In this part, I first executed the function in the usual way in the decoder, then I also performed the function with the method requested in the question.
  You can find the first function in "decodinghamming4_7.m" and the function that requested in the question is in " syndrome_hamming_decoder.m "
There are two approaches to decoding Hamming 4: 7 encoding in the book:
i.	Hard decision
ii.	Soft decision
I executed both of these scenarios in this function, but the output of the function gives us the result of a hard decision as to the output. Now we will deal with how to write it.
For both of these methods, a keyword must be created that has coding results from all possible inputs into a matrix and pass it to the function. The construction of this matrix is as follows
 
    a = linspace(0,15,16);
    a = de2bi(a);
    for i = 1:length(a)
        code(i,:)= hamming4_7(a(i,:));
    end
>Now for a hard decision, we have to calculate the input distance to our keywords and report it as a minimum. You can see its implementation in the following code snippet.
 
    %Hard decision
    input_H = (1- 2 *input <0);
    distance = sum(abs(ones(16,1)*input_H - code),2);
    [min_func, index_h] = min(distance);
    massage_recieved_h = code(index_h,1:4);
> For the soft decision, we have to calculate the correlation between the input and all keywords and this time report the maximum as the output. You can see the implementation of this algorithm in the following code snippet.
 
     %soft decision
     input_s = 1- 2 *input ;
     [max_func, index_s] = max(input_s*(1-2*code)');
     massage_recieved_s = code(index_s,1:4);

 > for checking the decoder function that we write, I give the previous part output to the function input and as we see the output is the answer that we expected
 
> But in the question we are asked to execute the decoder function with the " syndrome " method for "rigid decision making", which is not very complicated; Only we have to form the decoder defining matrices, which are "H", "G" and "A".Then I performed the method described in the book "Prakis Salehi" and performed the decoder in the following way.
 
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
 
> To examine as closely as possible the differences between the two methods of decoding Hamming, I plotted the BER diagram in terms of signal-to-noise ratio for both "soft decision" and "hard decision" modes. I also marked the theoretical limits of these two values on the graph.

 <p align="center">
<image align="center" src = "images/three.png"    width="600">
</p>
  
> As it turns out, the "soft decision" method performs better than the "hard decision" method because of the use of correlation.Also, in both cases, the actual performance is weaker than the theoretical limit, which is not far from our expectations

  
### 2.2 Employing error-handling in a communication channel
Consider transmission of 12.5kB of information using 1000 bit frames between a sender and the corresponding receiver through a noisy channel. Assuming the BPSK modulation scheme and AWGN channel model, simulate the following.

#### 2.2.1.  Simulate an error detection scenario by adding one parity bit to every data frame such that the total number of ones is even. At the receiver parity bits are checked and if an error is detected, the receiver requests retransmission of that frame. Change Eb/No from 1 to 10 dB and plot the actual number of bytes sent (12.5kB + parity overhead + retransmission overhead) versus Eb/No. Also plot bit error rate (BER) of information bits versus Eb/No.
  
> To model the transmission in a noisy channel, we must first prepare the sent message. To do this, we separate the packets of 1000 bits of data and We use the remainder of dividing the sum of the packet members by two as a parity, which is given in the following code snippet.

    parity = mod(sum(packet_data),2);
    txData = [packet_data parity]';

> Now, using the ready-made MATLAB modulator "comm.BPSKModulator" and the MATLAB noise function "awgn” and then demodulating the channel output, we receive the packets in the receiver. You can see these in the code snippet below.

    modSig = bpskModulator(txData);        % Modulate
    rxSig = awgn(modSig,snr);                % Pass through AWGN
    rxData = bpskDemodulator(rxSig);      % Demodulate

> Now, to ensure the accuracy of resending, we calculate the "parity" again and compare it with the "parity" in the package. It was equal to go to the next package, but if not, we send it again and repeat the review.
  
    if mod(sum(rxData(1:1000)),2) ~= rxData(1001)
          counter = counter;
    elseif mod(sum(rxData(1:1000)),2) == rxData(1001)
          counter = counter + 1000;
          temp = temp+ sum(abs(txData - rxData));
    end
  
> Finally, I drew two graphs "BER" to the "E/n" and "total number of bits sent" to the "E/n", which can be seen below in logarithmic scale.
  
  <p align="center">
<image align="center" src = "images/four.png" width="600">
</p>
   <p align="center">
<image align="center" src = "images/five.png" width="600">
</p>

  >   As we expected, for high values of signal to noise, noise is practically ineffective, and this is clearly shown on the diagram. . But why it isnt from 0 to 10? For finding the reason for that I plot the BER diagram in linear scale below
    
<p align="center">
<image align="center" src = "images/six.png" width="600">
</p>
 
> The linear scale diagram clearly shows why the value in the high signal-to-noise ratio is not specified on the logarithmic diagram; Because the value with the accuracy limit of MATLAB was equal to 0 and it is not possible to display 0 on the logarithmic scale
 
 #### 2.2.2. Simulate an error correction scenario by employing (7,4) Hamming code you have written in the previous part. The procedure is shown in Fig. 1. Change Eb/No from 1 to 10 dB. Plot bit error rate (BER) of information bits versus Eb/No.
 
 > As in the previous section, to send a message, we must first create our packets with the requested method.To do this, first separate the bits of each packet, which was 1000 bits, similar to the previous part, and convert the 4-bit 4-bit using the function obtained in 2.1.2 into a 4-to-7 Hamming encoding. Which is given in the MATLAB code snippet below.


    temp_packet = [];
            for j = 0:4:999
                packet_data = x(j + counter:j + counter+3);
                a = hamming4_7(packet_data);
                temp_packet = [temp_packet a];
            end
    txData = temp_packet'

Now, as in the previous part, using the same functions, with the BSK modulation, we pass the packet through the noisy channel. The following code snippet is used for this purpose.

     modSig = bpskModulator(txData)  ;      % Modulate
     rxSig = awgn(modSig,snr)  ;             % Pass through AWGN
     rxData = bpskDemodulator(rxSig) ;     % Demodulate

> Now we need to separate the input of the receiver by 7 bits to 7 bits and decode it by the decoder function that I wrote in section 2.1.3 and extract the message. As shown in the code below.
     temp_packet_received = [];
     for j = 1:7:length(rxData)
          packet_data = rxData(j :j +6)';
          a = encoding4_7(packet_data,code);
          temp_packet_received = [temp_packet_received a];
     end
     recieved = temp_packet_received;
> In this method, the number of bits sent is fixed, so I just drew the "BER" diagram, which is given in logaritmic scale below.
 
<p align="center">
<image align="center" src = "images/seven.png" width="600">
</p>
 
> As we expected, the error in the high noise signal is practically zero. But why it isnt from 0 to 10?
For finding the reason for that I plot the BER diagram in linear scale below 
 
 <p align="center">
<image align="center" src = "images/eight.png" width="600">
</p>
  
>  The linear scale diagram clearly shows why the value in the high signal-to-noise ratio is not specified on the logarithmic diagram; Because the value with the accuracy limit of MATLAB was equal to 0 and it is not possible to display 0 on the logarithmic scale

#### 2.2.3. Implement a Hybrid ARQ (HARQ) scenario by mixing parts 1 and 2. For this part assume there are 999 information bits plus one parity bit (1000 bits) that enter the Hamming encoder. Change Eb/No from 1 to 10 dB Plot the actual number of bytes sent (12.5kB + Hamming code overhead + parity overhead + retransmission overhead) versus Eb/No. Also plot bit error rate (BER) of information bits versus Eb/No.

>  Similar to the previous sections, we start our work by forming packages.Put 999 bits in a packet and put a parity bit similar to part 2.2.1 at the end of it, now give 1000 bits packet 4bits to 4 bit to the function we wrote in part 2.1.2 and make our packet coded by hamming "4-7". We see this algorithm in the following code snippet.

     packet_data = x(counter:counter+998);
     parity = mod(sum(packet_data),2);
     txData = [packet_data parity]';
     temp_packet = [];
     for j = 1:4:length(txData)
          a = hamming4_7(txData(j:j+3)');
          temp_packet = [temp_packet a];    
     end
     txData1 = temp_packet';

Now, as in the previous parts, using the same functions, with the BSK modulation, we pass the packet through the noisy channel. The following code snippet is used for this purpose.
  
     modSig = bpskModulator(txData)  ;      % Modulate
     rxSig = awgn(modSig,snr)  ;             % Pass through AWGN
     rxData = bpskDemodulator(rxSig) ;     % Demodulate

> Now we need to decode the received packet using the decoder function that we wrote in section 2.1.3. Now at the end we have to recalculate the bit parity and compare it with the received parity. We had to go to the next packet; But if it is not equal, we send the packet again and repeat the above algorithm.
  
  
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

  
> Now, I drew two graphs "BER" to the "E/n" and "total number of bits sent" to the "E/n" in logarithmic scale, which can be seen below.
  
<p align="center">
<image align="center" src = "images/eight.png" width="600">
</p>
