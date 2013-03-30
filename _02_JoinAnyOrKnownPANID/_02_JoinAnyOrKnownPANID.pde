/*  With this program you can check if routers/end devices have successfully 
 *  joined a coordinator.
 *    If setPAN(0) they will join any available network
 *    If setPAN(panID) they will only try to join that network
 *  To limit the size of future programs this functionality has been added to the API in
 *  'commUtils.h'
 *  
 *  State = STABLE
 *    If errors try with other XBee. Normally a setPAN error means the XBee has crashed.
 *    Try to reset via X-CTU: restore button will not help but normally changeing the
 *    device type (Coord/Router/EndDev) will erase and write all parameters. Then just
 *    keep trying...
 */
 
 
// PAN ID to set in order to search a coordinator 
//uint8_t PANID[8]={ 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};   //To join any PAN ID
uint8_t PANID[8]={ 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA}; 
 
void setup() 
{ 
  
     USB.begin();                                      // init USB port 
     USB.println("Router joins unknown network");
     
     xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);              // init XBee
     xbeeZB.ON();                                      // opens UART and switches the XBee ON
     delay(1000); 
    
     /////////////////////////////////////
     // 1. Dissociation process
     /////////////////////////////////////
    
     // 1.1  Set PANID: 0x0000000000000000 
        xbeeZB.setPAN(PANID); 
   
     // 1.2. check AT command flag
        if( xbeeZB.error_AT == 0 ) 
        {
            USB.println("\nPANID set OK");
        }else{
            USB.println("\nError while setting PANID"); 
        }
     
     // 1.3. set all possible channels to scan, channels from 0x0B to 0x18 (0x19 and 0x1A are excluded)
        xbeeZB.setScanningChannels(0x3F, 0xFF);
   
     // 1.4. check AT command flag  
        if( xbeeZB.error_AT == 0 )
        {
            USB.println("scanning channels set OK");
        }else {
            USB.println("Error while setting scanning channels"); 
        }
  
      // 1.5. set channel verification JV=1 in order to make the XBee module to scan new coordinator
         xbeeZB.setChannelVerification(1);
      
      // 1.6. check AT command flag    
         if( xbeeZB.error_AT == 0 )
         {
            USB.println("verification channel set OK");
         }
         else 
         {
            USB.println("Error while setting verification channel"); 
         }
   
     // 1.7 write values to XBee memory 
        xbeeZB.writeValues(); 
        
     // 1.8 reboot the XBee module 
        xbeeZB.OFF(); 
        delay(3000); 
        xbeeZB.ON(); 
        delay(3000); 
   
   
   
    /////////////////////////////////////
    // 2. Wait for Association 
    /////////////////////////////////////
   
        checkNetworkParams();
    
} 
 
void loop() 
{ 
     // Do nothing 
     delay(3000); 
}
 
 
 void checkNetworkParams()
 {
    // 2.1. get operating 64-b PAN ID
      xbeeZB.getExtendedPAN();
 
   // 2.2. wait until XBee module is associated
      xbeeZB.getAssociationIndication();
      
      while( xbeeZB.associationIndication != 0 ) 
      { 
          delay(4000); 
          
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
      xbeeZB.setChannelVerification(0);
      xbeeZB.writeValues();
      
   // 2.4. get network parameters 
      xbeeZB.getOperatingPAN();
      xbeeZB.getExtendedPAN();
      xbeeZB.getChannel();
      
      USB.print("operating 16-b PAN ID: ");
      USB.print(xbeeZB.operatingPAN[0],HEX);
      USB.println(xbeeZB.operatingPAN[1],HEX);
      USB.println();
    
      USB.print("operating 64-b PAN ID: ");
      USB.print(xbeeZB.extendedPAN[0],HEX);
      USB.print(xbeeZB.extendedPAN[1],HEX);
      USB.print(xbeeZB.extendedPAN[2],HEX);
      USB.print(xbeeZB.extendedPAN[3],HEX);
      USB.print(xbeeZB.extendedPAN[4],HEX);
      USB.print(xbeeZB.extendedPAN[5],HEX);
      USB.print(xbeeZB.extendedPAN[6],HEX);
      USB.println(xbeeZB.extendedPAN[7],HEX);
      USB.println();
    
      USB.print("channel: ");
      USB.println(xbeeZB.channel,HEX);
      USB.println();
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
