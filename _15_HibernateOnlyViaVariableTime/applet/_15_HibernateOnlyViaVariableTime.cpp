/*
 * Sample code from libelium: DOES NOT WORK like they say it should!!!
 *  Solution: the RTC must / may only be turned on AFTER the ifHibernate() function!!!!!!!!
 *
 *  STATE: CODE = STABLE BUT does not always work from the first time: you have to reset and play with the
 *         hibernate jumper until it accepts it...  If it doesn't work the processor loops instead of 
 *         going into hibernate and the green led blinks very fast. => Better luck next time
 */
 
#include "WProgram.h"
void setup();
void loop();
void hibInterrupt();
char * sleepTime = "00:00:00:10"; 
uint16_t time = 1;  // 1 = 10 sec  --> 2^16 gives a max sleep time of 7,58 days

void setup()
{
  // Init RTC
  //RTC.ON();
  
  // Checks if we come from a normal reset or an hibernate reset
  PWR.ifHibernate();
  
  RTC.ON();
  
  USB.begin();
  USB.println("usb started");
  
}

void loop()
{
  time = 1;
  USB.println("device enters loop");
  Utils.blinkLEDs(1000);
  
  xbeeZB.convertTime2Wait2Char(time);
  USB.println(xbeeZB.time2wake);
  time++;
  
  // If Hibernate has been captured, execute hte associated function
  if( intFlag & HIB_INT )
  {
    hibInterrupt();
  }
  

  
  USB.println("entering hibernate");
  // Set Waspmote to Hibernate, waking up after 10 seconds
  PWR.hibernate(xbeeZB.time2wake,RTC_OFFSET,RTC_ALM1_MODE2);
}

void hibInterrupt()
{
  USB.println("hibInterrupt");
  Utils.blinkLEDs(1000);
  Utils.blinkLEDs(1000);
  intFlag &= ~(HIB_INT);
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

