/*
 * setCounterToLEDs.pde:  sets a loop through nodes B->E and increases the time they
 *                        blink their leds
 */

#include "WProgram.h"
void setup();
void loop();
void sendMessage(const char * destination, const char * message);
int receiveMessage();
void blinkLEDs(int times);
void printOwnMacAddress();
void setNodeIdentifier();
bool hasAsMacAddress(char * testAddress);
void printCurrentNetworkParams();
void printAssociationState();
packetXBee* paq_sent;
 //int8_t state=0;
 long previous=0;
 //char*  data="Data count:  \r\n";
char aux[500];
int count = 0;
char dataReceived[MAX_DATA];


char macLowOwn[9];
char macLowDest[9];
char macLowNodeA[9] = "4069737A";
char macLowNodeB[9] = "40697379";
char macLowNodeC[9] = "4069736C";
char macLowNodeD[9] = "40697377";
char macLowNodeE[9] = "4069737C";
 
 uint8_t panid[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA};
 char * DEST_MAC_ADDRESS = "0013A2004069736C";
//end device B: mac address:0013A20040697379
//gateway mac address:0013A2004069737A

 
 
void setup()
{
    // setup for Serial port over USB
    USB.begin();
    USB.println("PROGRAM: setCounterToLEDs - USB port started...\n");
    // Inits the XBee ZigBee library
    xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
   
    // Powers XBee
    xbeeZB.ON();
    // it is supposed that XBee SM=1 (Pin hibernate)   (only for END DEVICES) ATM: END DEVICE in 4: Cyclic sleep
    //xbeeZB.wake();
    delay(1000);
    
    if(!xbeeZB.setPAN(panid)) USB.println("setPAN ok");
    else USB.println("setPAN error");
  
    if(!xbeeZB.setScanningChannels(0xFF,0xFF)) USB.println("setScanningChannels ok");
    else USB.println("setScanningChannels error");
  
    if(!xbeeZB.setDurationEnergyChannels(3)) USB.println("setDurationEnergyChannels ok");
    else USB.println("setDurationEnergyChannels error");
  
    if(!xbeeZB.getAssociationIndication()) USB.println("getAssociationIndication ok");
    else USB.println("getAssociationIndication error");
    
    setNodeIdentifier();
  
    xbeeZB.writeValues();
   
    // wait until XBee module is associated
    while(xbeeZB.associationIndication != 0)
    {
      USB.println("\n\n-----> not associated <----------");
      printCurrentNetworkParams();
           
      delay(12000);
      xbeeZB.getAssociationIndication();
      printAssociationState();
    }
    
    delay(2000);
    
    printCurrentNetworkParams();
    printOwnMacAddress();
    USB.print("This is ");
    USB.println(xbeeZB.nodeID);
}

void loop()
{
  // Set params to send
  USB.println("Device enters loop");
  //char buf [100];
  //data[12] = *(itoa(i, buf, 10));
  
  //sprintf(aux,"%s%d%s%s","Message ", i, " from ", xbeeZB.nodeID); 
  //USB.println(aux);
  
  //printCurrentNetworkParams();
    
  if( (count == 0) && (hasAsMacAddress(macLowNodeB)) )
  {
      // I am node B, forward to node C:
      DEST_MAC_ADDRESS = "0013A2004069736C"; 
      
      // Send message (start)
      count = 1;
      USB.print("Count sent to sendMessage() = ");
      USB.println(count);
      char buffer[33];
      sendMessage(DEST_MAC_ADDRESS, itoa(count, buffer, 10) );      
  }
  else
  {
      // Receive message....
      USB.println("Waiting on receiveMessage()");
      count = receiveMessage();
      USB.println("Count from received message ");
      USB.println(count);
      // chose destination and forward message:
      if(count%4 == 0)
      {
          // I am node B, forward to node C:
          DEST_MAC_ADDRESS = "0013A2004069736C"; 
      }
      else if(count%4 == 1)
      {
           // I am node C, forward to node D:
           DEST_MAC_ADDRESS = "0013A20040697377";
      }
      else if(count%4 == 2)
      {
           // I am node D, forward to node E:
           DEST_MAC_ADDRESS = "0013A2004069737C";
      }
      else if(count%4 == 3)
      {
           // I am node E, forward to node B:
           DEST_MAC_ADDRESS = "0013A20040697379";
      }
      
      count++;
      // send message
      char buffer[33];
      sendMessage(DEST_MAC_ADDRESS, itoa(count, buffer, 10) );
      
      // delay
      delay(2000);
  }
}  


void sendMessage(const char * destination, const char * message)
{
    paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
    paq_sent->mode=UNICAST;
    paq_sent->MY_known=0;
    paq_sent->packetID=0x52;
    paq_sent->opt=0; 
    xbeeZB.hops=0;
    xbeeZB.setOriginParams(paq_sent, "5678", MY_TYPE);
    xbeeZB.setDestinationParams(paq_sent, destination, message, MAC_TYPE,DATA_ABSOLUTE);
    xbeeZB.sendXBee(paq_sent);
    USB.print("start printing xbeeZB.error_TX: ");
    USB.println(xbeeZB.error_TX);// print xbeeZB.error_TX
    if( !xbeeZB.error_TX )
    {
        //XBee.println("ok");
        USB.print("Device sends out challenge: ");
        USB.print(atoi(message));
        USB.println(" : OK");
        Utils.setLED(LED1, LED_ON);   // Ok, blink green LED
        delay(500);
        Utils.setLED(LED1, LED_OFF);
    }
    else
    { 
        USB.println("Challenge transmission error\n\n");
        Utils.setLED(LED0, LED_ON);   // Error, blink red LED
        delay(500);
        Utils.setLED(LED0, LED_OFF);
    }
    free(paq_sent);
    paq_sent=NULL;
}


int receiveMessage()
{
  // Waiting message
  previous=millis();
  bool received = false;
  while( !received/*(millis()-previous) < 5000*/ )
  {
    if( XBee.available() )
    {
      
      xbeeZB.treatData();
      USB.print("start printing xbeeZB.error_RX: ");
      USB.println(xbeeZB.error_RX);
      if( !xbeeZB.error_RX )
      {
        received = true;
          //while(xbeeZB.pos > 0)
          {              
              for(int f=0;f<xbeeZB.packet_finished[xbeeZB.pos-1]->data_length;f++)
              {
                  //USB.print(xbeeZB.packet_finished[xbeeZB.pos-1]->data[f],BYTE);
                  dataReceived[f] = xbeeZB.packet_finished[xbeeZB.pos-1]->data[f];
              }
              USB.print("Received number: ");
              USB.println((dataReceived));
              
              free(xbeeZB.packet_finished[xbeeZB.pos-1]);   
              xbeeZB.packet_finished[xbeeZB.pos-1]=NULL;
              xbeeZB.pos--;
              
              blinkLEDs(atoi(dataReceived));
              
          } //End while()
           return atoi(dataReceived);
      } //End if
      else
      {
          USB.println("No data received");        
      }
     
    }
  }
}

void blinkLEDs(int times)
{
    for(int i=0; i < times; i++)
    {
        Utils.blinkLEDs(500);
        delay(100);
    }
}
  
void printOwnMacAddress()
{
    xbeeZB.getOwnMacLow();
    xbeeZB.getOwnMacHigh();
    USB.print("Own MAC ADDRESS: ");
    USB.print("0013A200");
    USB.print(xbeeZB.sourceMacLow[0],HEX);
    USB.print(xbeeZB.sourceMacLow[1],HEX);
    USB.print(xbeeZB.sourceMacLow[2],HEX);
    USB.println(xbeeZB.sourceMacLow[3],HEX);
    
    //USB.print("DEST_MAC_ADDRESS[15] = ");
    //USB.println(DEST_MAC_ADDRESS[15]);
    
    //USB.print("xbeeZB.sourceMacLow[3] = ");
    //USB.println(xbeeZB.sourceMacLow[3],HEX);

    //Utils.hex2str(xbeeZB.sourceMacLow, macLowOwn, 4);
    //USB.println(macLowOwn);
    
    //uint32_t MLow = Utils.strtolong(macLowOwn);
    //USB.println(MLow);
    
    //if( hasAsMacAddress(macLowOwn) ) USB.println("TRUE");
    //if( hasAsMacAddress("40695679") ) USB.println("FALSE");
}

void setNodeIdentifier()
{
    xbeeZB.getOwnMacLow();
    Utils.hex2str(xbeeZB.sourceMacLow, macLowOwn, 4);
    if( hasAsMacAddress(macLowNodeA) ) xbeeZB.setNodeIdentifier("Node-A");  //the NI must be a 20 character max string
    if( hasAsMacAddress(macLowNodeB) ) xbeeZB.setNodeIdentifier("Node-B"); 
    if( hasAsMacAddress(macLowNodeC) ) xbeeZB.setNodeIdentifier("Node-C"); 
    if( hasAsMacAddress(macLowNodeD) ) xbeeZB.setNodeIdentifier("Node-D"); 
    if( hasAsMacAddress(macLowNodeE) ) xbeeZB.setNodeIdentifier("Node-E"); 
}

bool hasAsMacAddress(char * testAddress)
{
    /*
    macLowDest[0] = DEST_MAC_ADDRESS[8];
    macLowDest[1] = DEST_MAC_ADDRESS[9];
    macLowDest[2] = DEST_MAC_ADDRESS[10];
    macLowDest[3] = DEST_MAC_ADDRESS[11];
    macLowDest[4] = DEST_MAC_ADDRESS[12];
    macLowDest[5] = DEST_MAC_ADDRESS[13];
    macLowDest[6] = DEST_MAC_ADDRESS[14];
    macLowDest[7] = DEST_MAC_ADDRESS[15];
    USB.println(macLowDest);   
    */
    //return (! Utils.strCmp(testAddress, "40697379", Utils.sizeOf(testAddress)) );
    return (! Utils.strCmp(testAddress, macLowOwn, Utils.sizeOf(testAddress)) );
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

