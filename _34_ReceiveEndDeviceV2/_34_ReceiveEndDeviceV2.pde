/*
 *  ------Waspmote XBee ZigBee Receiving Instructions from Gateway ---------
 *  This mote is configured as a end device.
 */
 
 //BJORN
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };

long previous = 0;
uint8_t i=0;

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };
 
 
void setup()
{
      USB.begin();
      USB.println("\nUSB port started\n");
  
      if( COMM.setupXBee() ) 
      USB.println("ERROR SETTING UP XBEE MODULE");
      
      // "year:month:date:nrDayOfWeek:hour:minute:second - day 1 = Sunday"
      RTC.setTime("13:04:04:05:15:00:00");
      USB.println(RTC.getTime());
    
      xbeeZB.setActiveSensorMaskWithTimes(6, TEMPERATURE, 30, BATTERY, 20, HUMIDITY, 50);  
}

void loop()
{
      int er = 0;
      USB.println("\nDevice enters loop\n");

      er = SensUtils.measureSensors(xbeeZB.activeSensorMask);
      if( er!= 0)
      {
         USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
         USB.println(er);
      }      
      
      USB.print("\nEndMeasuring, start check association\n");  
      er = COMM.checkNodeAssociation(LOOP);
      if( er!= 0)
      {
         USB.print("ERROR COMM.checkNodeAssociation(LOOP) returns: ");
         USB.println(er);
      }   

/*
      er = PackUtils.sendMeasuredSensors(dest, xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er);
          
      }      
*/
      previous = millis();
      er = COMM.sendMessage(dest, "ENDDEVICE");
      if( er!= 0 )
      {
           USB.print("\nERROR COMM.sendMessage() returns: ");
           USB.println(er); 
      }
      USB.print("time to send: ");
      USB.println(millis() - previous);
    
      er = COMM.receiveTest();
      if( er!= 0)
      {
           USB.print("\nERROR COMM.receiveMessages() returns: ");
           USB.println(er); 
      }
      
      USB.println("now sleeping");                
      xbeeZB.sleep();  // OK: (in WaspXBeeCore.h)
      //XBee.setMode(XBEE_SLEEP);  //DO NOT USE!! (NOT IMPLEMENTED BY LIBELIUM)!!! 


      //PWR.deepSleep("00:00:00:20", RTC_OFFSET, RTC_ALM1_MODE2, SENS_OFF);
      //PWR.deepSleep("00:00:00:40", RTC_OFFSET, RTC_ALM1_MODE2, SENS_OFF);
      PWR.deepSleep("00:00:00:25", RTC_OFFSET, RTC_ALM1_MODE2, SENS_OFF | UART1_OFF | BAT_OFF | RTC_OFF);
      //xbeeZB.ON();
      xbeeZB.wake();
      
      //RTC.ON();
      //XBee.setMode(ON);
      USB.println("awake");
      //previous = millis();
      
      //delay(500);
       
}

