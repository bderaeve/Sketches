/*
 *  ------Waspmote XBee ZigBee Sending & Receiving Example------
 *  Explanation: This example shows how to send and receive packets
 *  using Waspmote XBee ZigBee API
 */
 //router C MAC address:  0013A2004069736C
 #include "WProgram.h"
void setup();
void loop();
void waitingForMessage();
void sendAnswerBack();
bool sendMessage(const char * message, uint8_t * destination);
void printCurrentNetworkParams();
void printAssociationState();
packetXBee* paq_sent;
 int8_t state=0;
 long previous=0;
 char*  data="Response from Router! \r\n";
 uint8_t destination[8];
 char DESTINATION[9];
 uint8_t i=0;
 
 uint8_t panid[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA};
 
void setup()
{
  // setup for Serial port over USB
  USB.begin();
  USB.println("PROGRAM: RouterAnswersToEndDevice\nUSB port started...");
  // Inits the XBee ZigBee library
  xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);

  // Powers XBee
  xbeeZB.ON();
  // it is supposed that XBee SM=1 (Pin hibernate)   (only for END DEVICES; END DEVICE must be in SM=1: Cyclic sleep)
  xbeeZB.wake();
  delay(1000);
  
  USB.println("Router set up ok");
  xbeeZB.setNodeIdentifier("Router-C");
  //delay(5000);
  
     if(!xbeeZB.setPAN(panid)) USB.println("setPAN ok");
      else USB.println("setPAN error");
    
      if(!xbeeZB.setScanningChannels(0xFF,0xFF)) USB.println("setScanningChannels ok");
      else USB.println("setScanningChannels error");
    
      if(!xbeeZB.setDurationEnergyChannels(3)) USB.println("setDurationEnergyChannels ok");
      else USB.println("setDurationEnergyChannels error");
    
      if(!xbeeZB.getAssociationIndication()) USB.println("getAssociationIndication ok");
      else USB.println("getAssociationIndication error");
    
      xbeeZB.writeValues();
  
  // wait until XBee module is associated
  xbeeZB.getAssociationIndication();
  while(xbeeZB.associationIndication != 0)
  {
    USB.println("\n\n-----> not associated <----------");
    printCurrentNetworkParams();
         
    delay(12000);
    xbeeZB.getAssociationIndication();
    printAssociationState();
  }
}

void loop()
{
      USB.println("Router enters loop");
      
      printCurrentNetworkParams();
      
      waitingForMessage();
    
      delay(100);
}

void waitingForMessage()
{
    previous=millis();
    while( (millis()-previous) < 20000 )
    {
          if( XBee.available() )
          {
                xbeeZB.treatData();
                USB.print("start printing xbeeZB.error_RX:");
                USB.println(xbeeZB.error_RX);
                if( !xbeeZB.error_RX )
                {
                    USB.print("Data: ");                    
                    for(int f=0;f<xbeeZB.packet_finished[xbeeZB.pos-1]->data_length;f++)
                    {
                      USB.print(xbeeZB.packet_finished[xbeeZB.pos-1]->data[f],BYTE);
                    }
                    USB.println("");
                    
                    sendAnswerBack();
                    previous=millis();
                }
          }
          else
          {
            //USB.println("XBEE not available\r\n");
          }  
    }
}


 // Sending answer back
 void sendAnswerBack()
 {
     //while(xbeeZB.pos>0)
     //{           
           if( (xbeeZB.packet_finished[xbeeZB.pos-1]->naO[0]==0x56) && (xbeeZB.packet_finished[xbeeZB.pos-1]->naO[1]==0x78) )
           {
                 i = 0;
                 while(i<4)
                 {
                   destination[i]=xbeeZB.packet_finished[xbeeZB.pos-1]->macSH[i];
                   i++;
                 }
                 while(i<8)
                 {
                   destination[i]=xbeeZB.packet_finished[xbeeZB.pos-1]->macSL[i-4];
                   i++;
                 }
                 
                // USB.print("Destination: ");
                // USB.println(destination);
                
                //Sending the answer:
                //Utils.hex2str(destination, DESTINATION, 8);
                //USB.println(DESTINATION);
                sendMessage(data, destination);
           }
    //} 
 }
 
 
bool sendMessage(const char * message, uint8_t * destination)
{
      bool error = false;
      paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
      paq_sent->mode=UNICAST;
      paq_sent->MY_known=0;
      paq_sent->packetID=0x52;
      paq_sent->opt=0; 
      xbeeZB.hops=0;
      xbeeZB.setOriginParams(paq_sent, "5678", MY_TYPE);
      xbeeZB.setDestinationParams(paq_sent, destination, data, MAC_TYPE, DATA_ABSOLUTE);
      xbeeZB.sendXBee(paq_sent);
      USB.print("start printing xbeeZB.error_TX:");
      USB.println(xbeeZB.error_TX);// print xbeeZB.error_TX
      if( !xbeeZB.error_TX )
      {
          //XBee.println("ok");
          USB.println("Router sends out answer ok");
          Utils.setLED(LED1, LED_ON);   // Ok, blink green LED
          delay(500);
          Utils.setLED(LED1, LED_OFF);
          error = false;
      }
      else
      { 
          USB.println("Answer transmission error\n\n");
          Utils.setLED(LED0, LED_ON);   // Error, blink red LED
          delay(500);
          Utils.setLED(LED0, LED_OFF);
          error = true;
      }
      free(paq_sent);
      paq_sent=NULL;
      return error;
}  


void printCurrentNetworkParams()
{
    USB.print("operatingPAN: ");            // get operating PAN ID 
    xbeeZB.getOperatingPAN();
    USB.print(xbeeZB.operatingPAN[0],HEX);
    USB.println(xbeeZB.operatingPAN[1],HEX);
  
    USB.print("extendedPAN: ");              // get operating 64-b PAN ID 
    xbeeZB.getExtendedPAN();
    USB.print(xbeeZB.extendedPAN[0],HEX);
    USB.print(xbeeZB.extendedPAN[1],HEX);
    USB.print(xbeeZB.extendedPAN[2],HEX);
    USB.print(xbeeZB.extendedPAN[3],HEX);
    USB.print(xbeeZB.extendedPAN[4],HEX);
    USB.print(xbeeZB.extendedPAN[5],HEX);
    USB.print(xbeeZB.extendedPAN[6],HEX);
    USB.println(xbeeZB.extendedPAN[7],HEX);
  
    USB.print("channel: ");
    xbeeZB.getChannel();
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


int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

