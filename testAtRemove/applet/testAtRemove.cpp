/*
 *  Explanation: Sending average sensor values to Router/Coordinator
 *  Remarks: Tested and verified on 18/03/2013
 *    Association after sleep always works (correct PAN and Channel), however
 *    sometimes xbeeZB.error_TX = 2
 *
 */
#include "WProgram.h"
void setup();
void loop();
uint8_t i = 10;

void setup()
{
    USB.begin();
    USB.println("setup");
}


void loop()
{
      USB.println("Device enters loop");
      USB.println("i = ");
      USB.print( (int) i);
      i++;
      USB.println("i = ");
      USB.print( (int) i);
      
      xbeeZB.testFunc();
      USB.print("testVar = "); USB.println( (int) xbeeZB.testVar );
      
      ////////////////////////////////////////////////
      // 6. Entering Deep Sleep mode
      ////////////////////////////////////////////////
      USB.println("Entering deep sleep");
      RTC.ON();
      PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
    
      USB.begin();
      USB.println("wake");
       

}



int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

