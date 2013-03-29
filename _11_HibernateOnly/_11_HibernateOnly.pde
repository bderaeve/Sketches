/*
 * Sample code from libelium: DOES NOT WORK like they say it should!!!
 *  Solution: the RTC must / may only be turned on AFTER the ifHibernate() function!!!!!!!!
 *
 *  STATE: CODE = STABLE BUT does not always work from the first time: you have to reset and play with the
 *         hibernate jumper until it accepts it...  If it doesn't work the processor loops instead of 
 *         going into hibernate and the green led blinks very fast. => Better luck next time
 */


void setup()
{
  // Init RTC
  //RTC.ON();
  
  // Checks if we come from a normal reset or an hibernate reset
  PWR.ifHibernate();
  
  RTC.ON();
}

void loop()
{
  Utils.blinkLEDs(1000);
  
  // If Hibernate has been captured, execute hte associated function
  if( intFlag & HIB_INT )
  {
    hibInterrupt();
  }
  
  // Set Waspmote to Hibernate, waking up after 10 seconds
  PWR.hibernate("00:00:00:10",RTC_OFFSET,RTC_ALM1_MODE2);
}

void hibInterrupt()
{
  Utils.blinkLEDs(1000);
  Utils.blinkLEDs(1000);
  intFlag &= ~(HIB_INT);
}
