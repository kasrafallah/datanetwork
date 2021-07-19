//////////////////////////////////////////////////////////////
////             Assignment 4 network layer             //////
////                   DR.pakravan                      //////
////                   Kasra Fallah                     //////
//////////////////////////////////////////////////////////////
#include "ns3/command-line.h"
#include "ns3/config.h"
#include "ns3/uinteger.h"
#include "ns3/boolean.h"
#include "ns3/string.h"
#include "ns3/internet-stack-helper.h"
#include "ns3/ipv4-address-helper.h"
#include "ns3/udp-echo-helper.h"
#include "ns3/on-off-helper.h"
#include "ns3/flow-monitor-helper.h"
#include "ns3/ipv4-flow-classifier.h"
#include "ns3/netanim-module.h"
#include "ns3/animation-interface.h"
#include "ns3/point-to-point-layout-module.h"
#include "ns3/flow-monitor.h"
#include "ns3/flow-monitor-helper.h"
#include "ns3/flow-monitor-module.h"
#include <string>
#include <string.h>
#include <stdio.h>
#include <iostream>
#include <fstream>
#include <cassert>
#include <vector>
#include "ns3/core-module.h"
#include "ns3/network-module.h"
#include "ns3/internet-module.h"
#include "ns3/point-to-point-module.h"
#include "ns3/csma-module.h"
#include "ns3/applications-module.h"
#include "ns3/ipv4-static-routing-helper.h"
#include "ns3/ipv4-list-routing-helper.h"
#include "ns3/ipv4-global-routing-helper.h"

 using namespace ns3;

 using namespace std;

 int
 main (int argc, char *argv[])
 {
   NS_LOG_COMPONENT_DEFINE ("Kasrafallah_97109987 ");

   uint32_t PacketSize = 512 ; // Packet Size in Bytes
   uint32_t Nodes_N=9;
   uint32_t UDPport= 6 ;
   string DataRate("1Mbps");
   // Allow the user to override any of the defaults and the above
  CommandLine cmd;
  cmd.AddValue ("PacketSize", "size of application packet sent (Byte)", PacketSize);
  cmd.AddValue ("DataRate", "rate of packet sent (Mbps)", DataRate);
  cmd.Parse (argc, argv);

  PacketMetadata::Enable();
  Config::SetDefault("ns3::OnOffApplication::PacketSize", UintegerValue(PacketSize));
  Config::SetDefault("ns3::OnOffApplication::DataRate", StringValue(DataRate));
  Config::SetDefault ("ns3::Ipv4GlobalRouting::RespondToInterfaceEvents",BooleanValue(true));

   NodeContainer nodes ;
   nodes.Create(Nodes_N);

   //////////////////////////////////////
   ///// define Point-to-point links/////
   /////////////////////////////////////

   Ptr<Node> nA = nodes.Get(0);
   Ptr<Node> nB = nodes.Get(1);
   Ptr<Node> nC = nodes.Get(2);
   Ptr<Node> nD = nodes.Get(3);
   Ptr<Node> nE = nodes.Get(4);
   Ptr<Node> nF = nodes.Get(5);
   Ptr<Node> nG = nodes.Get(6);
   Ptr<Node> nH = nodes.Get(7);
   Ptr<Node> nI = nodes.Get(8);


   NodeContainer nAnB = NodeContainer (nA, nB);
   NodeContainer nAnH = NodeContainer (nA, nH);
   NodeContainer nBnC = NodeContainer (nB, nC);
   NodeContainer nBnI = NodeContainer (nB, nI);
   NodeContainer nBnH = NodeContainer (nB, nH);
   NodeContainer nCnD = NodeContainer (nC, nD);
   NodeContainer nCnI = NodeContainer (nC, nI);
   NodeContainer nDnE = NodeContainer (nD, nE);
   NodeContainer nDnF = NodeContainer (nD, nF);
   NodeContainer nDnI = NodeContainer (nD, nI);
   NodeContainer nEnF = NodeContainer (nE, nF);
   NodeContainer nFnG = NodeContainer (nF, nG);
   NodeContainer nFnI = NodeContainer (nF, nI);
   NodeContainer nGnH = NodeContainer (nG, nH);
   NodeContainer nGnI = NodeContainer (nG, nI);
   NodeContainer nHnI = NodeContainer (nH, nI);




   PointToPointHelper p2p;
   p2p.SetDeviceAttribute ("DataRate", StringValue ("5Mbps"));
   p2p.SetChannelAttribute ("Delay", StringValue ("2ms"));

   NetDeviceContainer dAdB = p2p.Install (nAnB);
   NetDeviceContainer dAdH = p2p.Install (nAnH);
   NetDeviceContainer dBdC = p2p.Install (nBnC);
   NetDeviceContainer dBdI = p2p.Install (nBnI);
   NetDeviceContainer dBdH = p2p.Install (nBnH);
   NetDeviceContainer dCdD = p2p.Install (nCnD);
   NetDeviceContainer dCdI = p2p.Install (nCnI);
   NetDeviceContainer dDdE = p2p.Install (nDnE);
   NetDeviceContainer dDdF = p2p.Install (nDnF);
   NetDeviceContainer dDdI = p2p.Install (nDnI);
   NetDeviceContainer dEdF = p2p.Install (nEnF);
   NetDeviceContainer dFdG = p2p.Install (nFnG);
   NetDeviceContainer dFdI = p2p.Install (nFnI);
   NetDeviceContainer dGdH = p2p.Install (nGnH);
   NetDeviceContainer dGdI = p2p.Install (nGnI);
   NetDeviceContainer dHdI = p2p.Install (nHnI);

   NS_LOG_INFO("Setting routing Protocols");
   Ipv4StaticRoutingHelper staticRouting;
   Ipv4GlobalRoutingHelper globalRouting;
   Ipv4ListRoutingHelper list ;
   list.Add(staticRouting,0);
   list.Add(globalRouting,10);
   // Install network stacks on nodes
   InternetStackHelper internet;
   internet.SetRoutingHelper(list);
   internet.Install(nodes);

   ////////////////////////////////////
   // define IP addresses for nodes///
   //////////////////////////////////

   Ipv4AddressHelper ipv4;
   ipv4.SetBase ("10.1.1.0", "255.255.255.0");
   Ipv4InterfaceContainer iAiB = ipv4.Assign (dAdB);
   iAiB.SetMetric(0,6);
   iAiB.SetMetric(1,6);
   ipv4.SetBase ("10.1.2.0", "255.255.255.0");
   Ipv4InterfaceContainer iAiH = ipv4.Assign (dAdH);
   iAiH.SetMetric(0,2);
   iAiH.SetMetric(1,2);
   ipv4.SetBase ("10.1.3.0", "255.255.255.0");
   Ipv4InterfaceContainer iBiC = ipv4.Assign (dBdC);
   iBiC.SetMetric(0,3);
   iBiC.SetMetric(1,3);
   ipv4.SetBase ("10.1.4.0", "255.255.255.0");
   Ipv4InterfaceContainer iBiI = ipv4.Assign (dBdI);
   iBiI.SetMetric(0,1);
   iBiI.SetMetric(1,1);
   ipv4.SetBase ("10.1.5.0", "255.255.255.0");
   Ipv4InterfaceContainer iBiH = ipv4.Assign (dBdH);
   iBiH.SetMetric(0,7);
   iBiH.SetMetric(1,7);
   ipv4.SetBase ("10.1.6.0", "255.255.255.0");
   Ipv4InterfaceContainer iCiD = ipv4.Assign (dCdD);
   iCiD.SetMetric(0,6);
   iCiD.SetMetric(1,6);
   ipv4.SetBase ("10.1.7.0", "255.255.255.0");
   Ipv4InterfaceContainer iCiI = ipv4.Assign (dCdI);
   iCiI.SetMetric(0,5);
   iCiI.SetMetric(1,5);
   ipv4.SetBase ("10.1.8.0", "255.255.255.0");
   Ipv4InterfaceContainer iDiE = ipv4.Assign (dDdE);
   iDiE.SetMetric(0,2);
   iDiE.SetMetric(1,2);
   ipv4.SetBase ("10.1.9.0", "255.255.255.0");
   Ipv4InterfaceContainer iDiF = ipv4.Assign (dDdF);
   iDiF.SetMetric(0,1);
   iDiF.SetMetric(1,1);
   ipv4.SetBase ("10.1.10.0", "255.255.255.0");
   Ipv4InterfaceContainer iDiI = ipv4.Assign (dDdI);
   iDiI.SetMetric(0,4);
   iDiI.SetMetric(1,4);
   ipv4.SetBase ("10.1.11.0", "255.255.255.0");
   Ipv4InterfaceContainer iEiF = ipv4.Assign (dEdF);
   iEiF.SetMetric(0,3);
   iEiF.SetMetric(1,3);
   ipv4.SetBase ("10.1.12.0", "255.255.255.0");
   Ipv4InterfaceContainer iFiG = ipv4.Assign (dFdG);
   iFiG.SetMetric(0,2);
   iFiG.SetMetric(1,2);
   ipv4.SetBase ("10.1.13.0", "255.255.255.0");
   Ipv4InterfaceContainer iFiI = ipv4.Assign (dFdI);
   iFiI.SetMetric(0,2);
   iFiI.SetMetric(1,2);
   ipv4.SetBase ("10.1.14.0", "255.255.255.0");
   Ipv4InterfaceContainer iGiI = ipv4.Assign (dGdI);
   iGiI.SetMetric(0,1);
   iGiI.SetMetric(1,1);
   ipv4.SetBase ("10.1.15.0", "255.255.255.0");
   Ipv4InterfaceContainer iGiH = ipv4.Assign (dGdH);
   iGiH.SetMetric(0,5);
   iGiH.SetMetric(1,5);
   ipv4.SetBase ("10.1.16.0", "255.255.255.0");
   Ipv4InterfaceContainer iHiI = ipv4.Assign (dHdI);
   iHiI.SetMetric(0,3);
   iHiI.SetMetric(1,3);




   Ipv4GlobalRoutingHelper::PopulateRoutingTables ();



    PacketSinkHelper UDPsink("ns3::UdpSocketFactory",InetSocketAddress(Ipv4Address::GetAny () , UDPport));
   ApplicationContainer App;
   NodeContainer SourceNode = NodeContainer (nodes.Get (0));
   NodeContainer SinkNode = NodeContainer (nodes.Get (4));




   App = UDPsink.Install (SinkNode);
   App.Start (Seconds (0.0));
   App.Stop (Seconds (10.0));

   Address E_Address(InetSocketAddress(iEiF.GetAddress (0) ,UDPport));

   OnOffHelper UDPsource ("ns3::UdpSocketFactory",E_Address);
   UDPsource.SetAttribute ("OnTime",StringValue ("ns3::ConstantRandomVariable[Constant=1]"));
   UDPsource.SetAttribute ("OffTime",StringValue ("ns3::ConstantRandomVariable[Constant=0]"));
   App=UDPsource.Install(SourceNode);
   App.Start (Seconds (1.0));
   App.Stop (Seconds (10.0));

   AnimationInterface anim("first.xml");


   anim.SetConstantPosition(nA,0,8);
   anim.SetConstantPosition(nB,8,0);
   anim.SetConstantPosition(nC,16,0);
   anim.SetConstantPosition(nD,24,0);
   anim.SetConstantPosition(nE,32,8);
   anim.SetConstantPosition(nF,24,16);
   anim.SetConstantPosition(nG,16,16);
   anim.SetConstantPosition(nH,8,16);
   anim.SetConstantPosition(nI,16,8);



   Ptr<OutputStreamWrapper> stream1 = Create<OutputStreamWrapper> ("Table1", std::ios::out);
   Ipv4GlobalRoutingHelper helper2;
   helper2.PrintRoutingTableAllAt(Seconds(2.0),stream1);



   Ptr<Node> node1=nodes.Get(8);
   Ptr<Ipv4> ipv41=node1->GetObject<Ipv4>();
   Simulator::Schedule(Seconds(3),&Ipv4::SetDown,ipv41,1);
   Simulator::Schedule(Seconds(3),&Ipv4::SetDown,ipv41,2);
   Simulator::Schedule(Seconds(3),&Ipv4::SetDown,ipv41,3);
   Simulator::Schedule(Seconds(3),&Ipv4::SetDown,ipv41,4);
   Simulator::Schedule(Seconds(3),&Ipv4::SetDown,ipv41,5);
   Simulator::Schedule(Seconds(3),&Ipv4::SetDown,ipv41,6);

   Ptr<OutputStreamWrapper> stream2 = Create<OutputStreamWrapper> ("Table2", std::ios::out);
   helper2.PrintRoutingTableAllAt(Seconds(4.0),stream2);


   Simulator::Stop (Seconds (10.0));
   Simulator::Run ();
   Simulator::Destroy ();

   return 0;
 }


