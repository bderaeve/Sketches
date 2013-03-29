/*
 * Testing the convertTime2Wait2Char(uint16_t time) function in 'WaspXBeeZBNode.cpp'
 *  For extensive debugging make sure NODE_TIME_DEBUG is #defined in 'WaspXBeeZBNode.h'!
 */
 
//char * sleepTime = "00:00:00:10"; 
//uint16_t time = 1;  // 1 = 10 sec  --> 2^16 gives a max sleep time of 7,58 days

#include "WProgram.h"
void setup();
void loop();
void setup()
{
 
      USB.begin();
      USB.println("usb started\n");
  
}

void loop()
{
      USB.println("device enters loop\n");
    
      xbeeZB.convertTime2Wait2Char(1);      //00:00:00:10
      USB.println(xbeeZB.time2wake);
      xbeeZB.convertTime2Wait2Char(6);      //00:00:01:00
      USB.println(xbeeZB.time2wake);
      xbeeZB.convertTime2Wait2Char(10);     //00:00:01:40
      USB.println(xbeeZB.time2wake);
      xbeeZB.convertTime2Wait2Char(360);    //00:01:00:00
      USB.println(xbeeZB.time2wake);
      xbeeZB.convertTime2Wait2Char(375);    //00:01:02:30
      USB.println(xbeeZB.time2wake);
      xbeeZB.convertTime2Wait2Char(8640);   //01:00:00:00
      USB.println(xbeeZB.time2wake);
      xbeeZB.convertTime2Wait2Char(8639);   //00:23:59:50
      USB.println(xbeeZB.time2wake);
      xbeeZB.convertTime2Wait2Char(8650);   //01:00:01:40
      USB.println(xbeeZB.time2wake);
      xbeeZB.convertTime2Wait2Char(17285);   //02:00:00:50
      USB.println(xbeeZB.time2wake);
      xbeeZB.convertTime2Wait2Char(25919);   //01:00:01:40
      USB.println(xbeeZB.time2wake);
      
      delay(20000);
}



int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

