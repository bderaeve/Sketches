/*
 *  This program shows how to send packets to a gateway
 *  indicating the MAC address of the receiving XBee module. 
 */ 


uint8_t PANID[8]={ 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA};
//Pointer to an XBee packet structure 
packetXBee * paq_to_send;

//Destination MAC address
char * DEST_MAC_ADDRESS = "0013A2004069737A";

//Data
char * data = "Test message!";


void setup()
{
    USB.begin();
    USB.println("PROGRAM: SendPackets.pde");
    
    xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);    // Inits the XBee ZigBee library
    xbeeZB.ON();                            // Powers XBee
    delay(3000);
    //xbeeZB.wake();                          // it is supposed that XBee SM=1 (Pin hibernate)
    
    joinPAN();
    checkNetworkParams();
}  


void loop()
{
    // 1. Set params of packet to send
    paq_to_send = (packetXBee *) calloc(1,sizeof(packetXBee)); 
    paq_to_send->mode = UNICAST;
    
    paq_to_send->MY_known=0;   // set 16-bit NA unknown
    paq_to_send->packetID=0x52; // set ID application level
    paq_to_send->opt=0; 
    xbeeZB.hops=0;
    
    
    //! It sets the origin parameters, such as the sender address
    /*!
      \param packetXBee* paq : a packetXBee structure where some parameters should have been filled before calling this function. After this call, this structure is filled with the corresponding address and data
      \param char* address : origin identification (Netowrk Address, MAC Address or Node Identifier)
      \param uint8_t type : origin identification type (MAC_TYPE,MY_TYPE or NI_TYPE)
      \return '1' on success
     */
    xbeeZB.setOriginParams(paq_to_send, "5678", MY_TYPE);
    
    // 2. Set destination XBee parameters to packet
    xbeeZB.setDestinationParams(paq_to_send, DEST_MAC_ADDRESS, data, MAC_TYPE,DATA_ABSOLUTE);
    
   // 3. Send XBee packet
   xbeeZB.sendXBee(paq_to_send);
 
   // 4. Check TX flag
   if( !xbeeZB.error_TX )
   {
       XBee.println("TX flag ok\n\n");
       Utils.setLED(LED1, LED_ON);   // Ok, blink green LED
       delay(500);
       Utils.setLED(LED1, LED_OFF);
   }
   else
   {
       XBee.println("TX flag error\n\n");
       Utils.setLED(LED0, LED_ON);   // Error, blink red LED
       delay(500);
       Utils.setLED(LED0, LED_OFF);
   }  
   // 5. Free variables
   free(paq_to_send);
   paq_to_send = NULL;
   
   // 6. Wait 5s
   delay(5000);
}  


void joinPAN()
{
    if(!xbeeZB.setPAN(PANID)) USB.println("setPAN ok");
    else USB.println("setPAN error");
  
    if(!xbeeZB.setScanningChannels(0xFF,0xFF)) USB.println("setScanningChannels ok");
    else USB.println("setScanningChannels error");
  
    if(!xbeeZB.setDurationEnergyChannels(3)) USB.println("setDurationEnergyChannels ok");
    else USB.println("setDurationEnergyChannels error");
    
    if(!xbeeZB.setChannelVerification(1)) USB.println("setChannelVerification ok");
    else USB.println("setChannelVerification error");
  
    if(!xbeeZB.getAssociationIndication()) USB.println("getAssociationIndication ok");
    else USB.println("getAssociationIndication error");
  
    xbeeZB.writeValues();
    
    xbeeZB.OFF(); 
    delay(3000); 
    xbeeZB.ON(); 
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
      Utils.blinkLEDs(200);
      Utils.blinkLEDs(200);
      Utils.blinkLEDs(200);
      
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
