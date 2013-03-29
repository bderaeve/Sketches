/*  
 * Find other XBee modules in the network
 * Discovery nodes function is used to discover and to report all modules of its current operating channel and PAN ID.
 *
 * Related variables
 *    xbeeZB.totalScannedBrothers → stores the number of brothers discovered.
 *    xbeeZB.scannedBrothers → ‘Node’ structure array that stores in each position the info related to each found node.
 */
 
void setup()
{
      USB.begin();
      USB.println("PROGRAM: DiscoverNodes - USB port started...\n");
      
      // 1. Init XBee
      xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
      
          //Powers XBee
          xbeeZB.ON();
          delay(3000);
      
      // 2. Check network parameters
      checkNetworkParams();
}

void loop()
{
      // 3. Scan network
      USB.println("\nScanning network. This will take up to 10 seconds.");
      xbeeZB.scanNetwork();    //Discovery nodes
      
      // 4. Print info
      USB.print("\n\ntotalScannedBrothers: ");
      USB.println(xbeeZB.totalScannedBrothers,DEC);
      
      printScannedNodesInformation();
      
      //TODO DEEP SLEEP
      delay(30000);
}


void printScannedNodesInformation()
{
      for(char i=0; i<xbeeZB.totalScannedBrothers; ++i)
      {
            USB.println("\n---------------------------------------");
            USB.print("Node ID: ");
            for(char j=0; j<20; j++)
            {      
                  USB.print(xbeeZB.scannedBrothers[i].NI[j]);		
            }
            USB.print("\nMAC: ");
            //USB.print(xbeeZB.scannedBrothers[i].SH[0],HEX);
            //USB.print(xbeeZB.scannedBrothers[i].SH[1],HEX);
            //USB.print(xbeeZB.scannedBrothers[i].SH[2],HEX);
            //USB.print(xbeeZB.scannedBrothers[i].SH[3],HEX);
            USB.print("0013A200");
            USB.print(xbeeZB.scannedBrothers[i].SL[0],HEX);
            USB.print(xbeeZB.scannedBrothers[i].SL[1],HEX);
            USB.print(xbeeZB.scannedBrothers[i].SL[2],HEX);
            USB.println(xbeeZB.scannedBrothers[i].SL[3],HEX);
            USB.print("Device Type: ");
              switch(xbeeZB.scannedBrothers[i].DT)
              {
                  case 0: 
                    USB.println("Coordinator");
                    break;
                  case 1: 
                    USB.println("Router");
                    break;
                  case 2: 
                    USB.println("End Device");
                    break;
              }
            USB.print("16-bit Network Address: ");
            USB.print(xbeeZB.scannedBrothers[i].MY[0],HEX);
            USB.print(xbeeZB.scannedBrothers[i].MY[1],HEX);
            USB.print("\n16-bit Parent Network Address: ");
            USB.print(xbeeZB.scannedBrothers[i].PMY[0],HEX);
            USB.print(xbeeZB.scannedBrothers[i].PMY[1],HEX);
            USB.print("\nProfile ID (App layer addressing): ");
            USB.print(xbeeZB.scannedBrothers[i].PID[0],HEX);
            USB.print(xbeeZB.scannedBrothers[i].PID[1],HEX);
            USB.print("\nMANUFACTURER ID/ ");
            USB.print(xbeeZB.scannedBrothers[i].MID[0],HEX);
            USB.print(xbeeZB.scannedBrothers[i].MID[1],HEX);
            
            for(char j=0; j<20; j++)
            {      
                  xbeeZB.scannedBrothers[i].NI[j] = 0;		
            }
      }
      USB.println("\n---------------------------------------");
  
}

void checkNetworkParams()
{
    // 2.1. get operating 64-b PAN ID
      xbeeZB.getExtendedPAN();
 
   // 2.2. wait until XBee module is associated
      xbeeZB.getAssociationIndication();
      
      while( xbeeZB.associationIndication != 0 ) 
      { 
          delay(2000); 
          
          USB.println("\n\n-----> not associated <----------");
          // get operating PAN ID 
          xbeeZB.getOperatingPAN();
          USB.print("operatingPAN: ");
          USB.print(xbeeZB.operatingPAN[0],HEX);
          USB.println(xbeeZB.operatingPAN[1],HEX);
          
          // get operating 64-b PAN ID 
          xbeeZB.getExtendedPAN();
          USB.print("extendedPAN: ");
          USB.print(xbeeZB.extendedPAN[0],HEX);
          USB.print(xbeeZB.extendedPAN[1],HEX);
          USB.print(xbeeZB.extendedPAN[2],HEX);
          USB.print(xbeeZB.extendedPAN[3],HEX);
          USB.print(xbeeZB.extendedPAN[4],HEX);
          USB.print(xbeeZB.extendedPAN[5],HEX);
          USB.print(xbeeZB.extendedPAN[6],HEX);
          USB.println(xbeeZB.extendedPAN[7],HEX);
          
          USB.print("channel: ");
          USB.println(xbeeZB.channel,HEX);   
           
          // get association indication 
          xbeeZB.getAssociationIndication(); 
          printAssociationState();
      }
      
      USB.println("\n\nJoined a coordinator!"); 
      
   // 2.3. When XBee is associated print all network parameters unset channel verification JV=0
      //xbeeZB.setChannelVerification(0);
      //xbeeZB.writeValues();
      
   // 2.4. get network parameters 
      xbeeZB.getOperatingPAN();
      xbeeZB.getExtendedPAN();
      xbeeZB.getChannel();
      
      USB.print("\nOperating 16-b PAN ID: ");
      USB.print(xbeeZB.operatingPAN[0],HEX);
      USB.println(xbeeZB.operatingPAN[1],HEX);
          
      USB.print("Operating 64-b PAN ID: ");
      USB.print(xbeeZB.extendedPAN[0],HEX);
      USB.print(xbeeZB.extendedPAN[1],HEX);
      USB.print(xbeeZB.extendedPAN[2],HEX);
      USB.print(xbeeZB.extendedPAN[3],HEX);
      USB.print(xbeeZB.extendedPAN[4],HEX);
      USB.print(xbeeZB.extendedPAN[5],HEX);
      USB.print(xbeeZB.extendedPAN[6],HEX);
      USB.println(xbeeZB.extendedPAN[7],HEX);
     
      USB.print("Channel: ");
      USB.println(xbeeZB.channel,HEX);
} 

void printAssociationState()
{
  switch(xbeeZB.associationIndication)
  {
    case 0x00  :  USB.println("Successfully formed or joined a network");
                  break;
    case 0x21  :  USB.println("Scan found no PANs");
                  break;   
    case 0x22  :  USB.println("Scan found no valid PANs based on current SC and ID settings");
                  break;   
    case 0x23  :  USB.println("Valid Coordinator or Routers found, but they are not allowing joining (NJ expired)");
                  break;   
    case 0x24  :  USB.println("No joinable beacons were found");
                  break;   
    case 0x25  :  USB.println("Unexpected state, node should not be attempting to join at this time");
                  break;
    case 0x27  :  USB.println("Node Joining attempt failed");
                  break;
    case 0x2A  :  USB.println("Coordinator Start attempt failed");
                  break;
    case 0x2B  :  USB.println("Checking for an existing coordinator");
                  break;
    case 0x2C  :  USB.println("Attempt to leave the network failed");
                  break;
    case 0xAB  :  USB.println("Attempted to join a device that did not respond.");
                  break;
    case 0xAC  :  USB.println("Secure join error  :  network security key received unsecured");
                  break;
    case 0xAD  :  USB.println("Secure join error  :  network security key not received");
                  break;
    case 0xAF  :  USB.println("Secure join error  :  joining device does not have the right preconfigured link key");
                  break;
    case 0xFF  :  USB.println("Scanning for a ZigBee network (routers and end devices)");
                  break;
    default    :  USB.println("Unkown associationIndication");
                  break;
  }
}
