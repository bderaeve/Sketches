/*
 * Sample code from libelium: DOES NOT WORK like they say it should!!!
 *  Solution: the RTC must / may only be turned on AFTER the ifHibernate() function!!!!!!!!
 *
 *  STATE: CODE = STABLE BUT does not always work from the first time: you have to reset and play with the
 *         hibernate jumper until it accepts it...  If it doesn't work the processor loops instead of 
 *         going into hibernate and the green led blinks very fast. => Better luck next time
 */
 
char * sleepTime = "00:00:00:10"; 
uint16_t time = 1;  // 1 = 10 sec  --> 2^16 gives a max sleep time of 7,58 days

void setup()
{
 
  USB.begin();
  USB.println("usb started");
  
}

void loop()
{
  USB.println("device enters loop");

  xbeeZB.convertTime2Wait2Char(1);
  xbeeZB.convertTime2Wait2Char(6);
  xbeeZB.convertTime2Wait2Char(10);
  xbeeZB.convertTime2Wait2Char(360);
  xbeeZB.convertTime2Wait2Char(375);
  xbeeZB.convertTime2Wait2Char(8640);
  xbeeZB.convertTime2Wait2Char(8639);
  xbeeZB.convertTime2Wait2Char(8650);
  
 
 // USB.println(xbeeZB.time2wake);


}


