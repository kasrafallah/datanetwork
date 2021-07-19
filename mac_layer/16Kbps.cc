#include <fstream>
#include <iostream>
#include <string>
#include <cassert>
#include "ns3/core-module.h"
#include "ns3/csma-module.h"
#include "ns3/applications-module.h"
#include "ns3/internet-module.h"
#include "ns3/network-module.h"
#include "ns3/ipv4-global-routing-helper.h"
#include "ns3/netanim-module.h"
#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/csma-module.h"
#include "ns3/internet-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/applications-module.h"
#include "ns3/ipv4-global-routing-helper.h"
#include "ns3/netanim-module.h"
#include "ns3/flow-monitor-helper.h"
#include "ns3/ipv4-flow-classifier.h"
#include "ns3/mobility-module.h"
#include "ns3/ssid.h"
#include "ns3/config.h"
#include "ns3/nstime.h"
#include "ns3/gnuplot.h"
#include "ns3/gnuplot-helper.h"
using namespace ns3;

NS_LOG_COMPONENT_DEFINE ("UdpEchoExample");

int
main (int argc, char *argv[])
{
  Time::SetResolution (Time ::NS);
  LogComponentEnable ("UdpEchoExample", LOG_LEVEL_INFO);
  LogComponentEnable ("UdpEchoClientApplication", LOG_LEVEL_ALL);
  LogComponentEnable ("UdpEchoServerApplication", LOG_LEVEL_ALL);

NodeContainer myNodes;
myNodes.Create (6);

InternetStackHelper internet;
internet.Install (myNodes);



CsmaHelper csma;
csma.SetChannelAttribute ("DataRate", StringValue ("1024Kbps"));
csma.SetChannelAttribute ("Delay", TimeValue (MilliSeconds (2)));
NetDeviceContainer d = csma.Install (myNodes);




MobilityHelper mobility;
mobility.SetPositionAllocator ("ns3::GridPositionAllocator",
                               "MinX", DoubleValue (0.0),
                               "MinY", DoubleValue (0.0),
                               "DeltaX", DoubleValue (0.0),
                               "DeltaY", DoubleValue (0.0),
                               "GridWidth", UintegerValue (3),
                               "LayoutType", StringValue ("RowFirst"));


mobility.SetMobilityModel ("ns3::ConstantPositionMobilityModel");
mobility.Install (myNodes);
mobility.Install (myNodes);



Ipv4AddressHelper ipv4;
ipv4.SetBase ("10.0.78.0", "255.255.255.0");
Ipv4InterfaceContainer i = ipv4.Assign (d);

uint16_t port1 = 9;
uint16_t port2 = 9;
uint16_t port3 = 9;


UdpEchoServerHelper server1 (port1);
UdpEchoServerHelper server2 (port2);
UdpEchoServerHelper server3 (port3);


ApplicationContainer apps1 = server1.Install (myNodes.Get (3));
ApplicationContainer apps2 = server2.Install (myNodes.Get (4));
ApplicationContainer apps3 = server3.Install (myNodes.Get (2));

apps1.Start (Seconds (1.0));
apps1.Stop (Seconds (20.0));

apps2.Start (Seconds (1.0));
apps2.Stop (Seconds (20.0));

apps3.Start (Seconds (1.0));
apps3.Stop (Seconds (20.0));




uint32_t packetSize = 1600/8;
uint32_t maxPacketCount = 100000;
Time interPacketInterval = Seconds (0.1);

UdpEchoClientHelper client1 (Address(i.GetAddress(3)), port1);
UdpEchoClientHelper client2 (Address(i.GetAddress(4)), port2);
UdpEchoClientHelper client3 (Address(i.GetAddress(2)), port3);

client1.SetAttribute ("MaxPackets", UintegerValue (maxPacketCount));
client1.SetAttribute ("Interval", TimeValue (interPacketInterval));
client1.SetAttribute ("PacketSize", UintegerValue (packetSize));

client2.SetAttribute ("MaxPackets", UintegerValue (maxPacketCount));
client2.SetAttribute ("Interval", TimeValue (interPacketInterval));
client2.SetAttribute ("PacketSize", UintegerValue (packetSize));

client3.SetAttribute ("MaxPackets", UintegerValue (maxPacketCount));
client3.SetAttribute ("Interval", TimeValue (interPacketInterval));
client3.SetAttribute ("PacketSize", UintegerValue (packetSize));



apps1 = client1.Install (myNodes.Get (0));
apps2 = client2.Install (myNodes.Get (1));
apps3 = client3.Install (myNodes.Get (5));

apps1.Start (Seconds (2.0));
apps1.Stop (Seconds (20.0));

apps2.Start (Seconds (2.0));
apps2.Stop (Seconds (20.0));

apps3.Start (Seconds (2.0));
apps3.Stop (Seconds (20.0));



#if 0
//
// Users may find it convenient to initialize echo packets with actual data;
// the below lines suggest how to do this
//
client.SetFill (apps.Get (0), "Hello World");

client.SetFill (apps.Get (0), 0xa5, 1024);

uint8_t fill[] = { 0, 1, 2, 3, 4, 5, 6};
client.SetFill (apps.Get (0), fill, sizeof(fill), 1024);
#endif

AsciiTraceHelper ascii;
csma.EnableAsciiAll (ascii.CreateFileStream ("16Kbps.tr"));
csma.EnablePcapAll ("16Kbps", false);

  AnimationInterface anim("16Kbps.xml");
  anim.SetConstantPosition (myNodes.Get(0),0,0);
  anim.SetConstantPosition (myNodes.Get(3),0,20);
  anim.SetConstantPosition (myNodes.Get(1),0,40);
  anim.SetConstantPosition (myNodes.Get(4),40,0);
  anim.SetConstantPosition (myNodes.Get(5),40,20);
  anim.SetConstantPosition (myNodes.Get(2),40,40);




  FlowMonitorHelper flowmon;
  Ptr<FlowMonitor> monitor = flowmon.InstallAll ();


double totalbits = 0;
double totaldelay = 0;


  Simulator::Stop (Seconds (10));
  Simulator::Run ();

  monitor->CheckForLostPackets ();
  Ptr<Ipv4FlowClassifier> classifier = DynamicCast<Ipv4FlowClassifier> (flowmon.GetClassifier ());
  FlowMonitor::FlowStatsContainer stats = monitor->GetFlowStats ();

  for (std::map<FlowId, FlowMonitor::FlowStats>::const_iterator i = stats.begin (); i != stats.end (); ++i)
    {


      if (i->first > 0)
        {

          totalbits += i->second.rxBytes * 8.0;
          totaldelay += (i->second.delaySum).GetSeconds();
        }
    }
  std::cout << "Total Bits: " << totalbits << "\n";
  std::cout << "Generation Rate: " << packetSize * 8 * 6 / interPacketInterval * 1000000 << " Kbps \n";
  std::cout << "Throughput: " << totalbits/ 18 / 1000 << " Kbps\n";
  std::cout << "Average Delay: " << totaldelay/6 << " s ";
  return 0;

}
