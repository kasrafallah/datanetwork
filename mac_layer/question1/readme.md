
## Questions1

### Non-persistent CSMA


In this part, you will build a network topology and study performance parameters over different experiments.
First, create a network topology of 6 CSMA nodes as described in figure 2. These nodes use the CSMA
protocol for channel access at the link layer. The CSMA link bandwidth is 1024 Kbps, and the oneway link
delay is 2ms. Every node uses IPv4 at the Internet layer and owns an IP address in the range of "10.0.XY.0"
with netmask "255.255.255.0". (XY is the last two digits of your student number) The application layer uses
the UDP echo application, and echo messages have different data generation rates. There are three UDP
flows in this network, as given below.

• Flow 1: Node 1 → Node 4

• Flow 2: Node 2 → Node 5

• Flow 3: Node 6 → Node 3

Measure the performance of the CSMA protocol in terms of throughput and forwarding delay and plot a
graph (for every metrics, there should be one graph) for [16, 32, 64, 128, 256, 512, 1024] Kbps application layer
traffic generation rate.\

##### Notes:

• Throughput: Average amount of data bits successfully transmitted per unit time.
• Forwarding Delay: Average end to end delay (including the queuing delay and the transmission delay)
experienced by the CSMA frames.

• The implemented CSMA protocol in NS3 is Non-persistent CSMA.

• You need to measure the link layer performance or the network performance, not the per-node performance. Therefore you should consider all the CSMA frames from all the communication pairs while calculating the performance metrics.

• You need to change the packet size and the time interval between consecutive UDP echo packets, then find out the data generation rate. For instance, if a packet size is 16Kb and the time interval is 0.25 sec, then the data generation rate is 64Kbps.
