/*
 *  Test program for power saver mode
 *    STATE = 
 */

//BJORN
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA };
long previous = 0;

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };

uint16_t sortedTimes[4] = {20, 25, 60, 100};

char * sleepTime = "00:00:00:10";   

void setup()
{	
      // Checks if we come from a normal reset or a hibernate reset
      PWR.ifHibernate();

      // When out of hibernate: REDUCED SETUP, disable flag and goto loop()
      if( intFlag & HIB_INT )
      {
          USB.begin();
          xbeeZB.hibernateInterrupt();
          
          previous=millis();
          USB.print("\nAwake at"); USB.println(previous);
          USB.print("\n");
          
          //xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
          //xbeeZB.ON();
          //xbeeZB.wake(); 
      }
      
      // After powering on the node or hardware reset: FULL SETUP
      else
      {
          USB.begin();
          USB.println("usb started\n");
      
          if( COMM.setupXBee() ) 
              USB.println("ERROR SETTING UP XBEE MODULE");
          
          // "year:month:date:nrDayOfWeek:hour:minute:second - day 1 = Sunday"
          RTC.setTime("13:04:04:05:15:00:00");
          USB.println(RTC.getTime());
          
          //RTC.setTime("13:04:00:00:00:00:00");
          RTCUt.getTime();
          
          RTCUt.setNextTimeWhenToWakeUpViaOffset(4);
          
          /* param1 = number of sensors to measurePossible input:
           * other params can be: TEMPERATURE, HUMIDITY, PRESSURE, BATTERY, CO2, ANEMO, VANE , PLUVIO
           */    
          xbeeZB.setActiveSensorMask(4, TEMPERATURE, BATTERY, HUMIDITY, PRESSURE);
          xbeeZB.setActiveSensorTimes(4, 30, 20, 50, 100);
      }  
}

void loop()
{
      int er = 0;
      
      //previous=millis();
      //USB.print("\ntime\n"); USB.println(previous);

      USB.println("\ndevice enters loop\n");

      
      er = SensUtils.measureAndstoreSensorValues(xbeeZB.activeSensorMask);
      if( er!= 0)
      {
         USB.print("ERROR SensUtils.measureAndstoreSensorValues(uint16_t) returns: ");
         USB.println(er);
      }
      
      previous=millis();
      USB.print("\nEndMeasuringAndStoring\n"); USB.println(previous);     
      
      previous=millis();
      USB.print("\ntime\n at hibernate"); USB.println(previous);


      ////////////////////////////////////////////////
      // 6. Entering hibernate mode
      ////////////////////////////////////////////////
      xbeeZB.hibernate();
}




