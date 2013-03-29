/*
 * This program shows how to receive packets with the XBee on a Waspmote
 */
 
//Network address
#include "WProgram.h"
void setup();
void loop();
void checkNetworkParams();
void printAssociationState();
uint8_t network_address[2];

void setup()
{
    USB.begin();
    USB.println("PROGRAM: ReceivePackets.pde");
    
    // 1. Init XBEE
    xbeeZB.ON();
    delay(3000);
    
    // 2. Check association state
    checkNetworkParams();
}

void loop()
{
    //Waiting message
    USB.println("Waiting message");
    
    //! It checks if there is available data waiting to be read
    if( XBee.available() )
    {
        // Read a packet when XBee has noticed it to us
        xbeeZB.treatData();
        
        if( !xbeeZB.error_RX )
        {
            // read available packets
            while( xbeeZB.pos > 0 )
            {
                // Available information in 'xbeeZB.packet_finished' structure
                // HERE it should be introduced the User's packet treatment        
                // For example: show DATA field:
                USB.println("Received data: ");
                for(int i=0;i<xbeeZB.packet_finished[xbeeZB.pos-1]->data_length;i++)          
                {
                    // Print data payload
                    USB.print(xbeeZB.packet_finished[xbeeZB.pos-1]->data[i],BYTE);    
                }
                USB.println("");
                
                //free memory
                free(xbeeZB.packet_finished[xbeeZB.pos-1]); 
                
                //free pointer
                xbeeZB.packet_finished[xbeeZB.pos-1]=NULL; 
                
                //Decrement the received packet counter
                xbeeZB.pos--; 
            }
        }
      
    }
    
    delay(5000);
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
      //xbeeZB.setChannelVerification(0);
      //xbeeZB.writeValues();
      
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

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

