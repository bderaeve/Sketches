/*
 * Sample code from libelium: DOES NOT WORK like they say it should!!!
 *  Solution: if necessary the RTC must / may only be turned on AFTER the ifHibernate() function!!!!!!!!
 *
 *  STATE: CODE = STABLE BUT does not always work from the first time: you have to reset and play with the
 *         hibernate jumper until it accepts it...  If it doesn't work the processor loops instead of 
 *         going into hibernate and the green led blinks very fast. => Better luck next time
 */
 
#include "WProgram.h"
void setup();
void loop();
void hibInterrupt();
uint16_t time = 1;  // 1 = 10 sec  --> 2^16 gives a max sleep time of 7,58 days

void setup()
{
  
    PWR.ifHibernate();
   
    USB.begin();
    USB.println("\nPROGRAM: HibernateOnlyWithVariableTimeViaAPI\n");
  
}

void loop()
{ 
    USB.println("Device enters loop");
    
    // If Hibernate has been captured, execute the associated function
    if( intFlag & HIB_INT )
    {
        hibInterrupt();
    }
  
    xbeeZB.convertTime2Wait2Char(time);
    USB.print("Going into hibernate for: ");
    USB.println(xbeeZB.time2wake);
    
   
    PWR.hibernate(xbeeZB.time2wake, RTC_OFFSET, RTC_ALM1_MODE2);
}

void hibInterrupt()
{
      USB.println("Out of hibernate (interrupt)");
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

