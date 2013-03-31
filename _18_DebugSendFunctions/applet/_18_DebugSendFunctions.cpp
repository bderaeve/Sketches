/*
 * Test program to debug the send functions in 'CommUtils.h'
 *  Results: see screenshots
 */
 

#include "WProgram.h"
void setup();
void loop();
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A};  //Coordinator Bjorn address: 0013A2004069737A
const char * DEST_MAC_ADDRESS = "0013A2004069737A";

void setup()
{
 
      USB.begin();
      USB.println("usb started\n");
  
      if( COMM.setupXBee() ) 
          USB.println("ERROR SETTING UP XBEE MODULE");
}

void loop()
{
      USB.println("device enters loop\n");
    
     // This function is an exact copy of the function used in other IDE files but now calling
     // it from the API via the COMM object: RESULT: WORKS PERFECT (WITH TX = 0)
     COMM.sendMessageLocalWorking("TEST MESSAGE", DEST_MAC_ADDRESS);    //WORKS / HAS WORKED
     delay(1000);
     
     Pack.testPrinter();
     
     //PAQ.testPrinten();
     //SensUtils.testPrint();
     //COMM.testenPrinten();
     
     //xbeeZB.tester();
     
     //PAQ.testComm7();
     
     //COMM.sendMessageLocalWorkingWithType("TEST MESSAGE", IO_DATA, DEST_MAC_ADDRESS);    //WORKS / HAS WORKED
     //delay(1000);
     
}



int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

