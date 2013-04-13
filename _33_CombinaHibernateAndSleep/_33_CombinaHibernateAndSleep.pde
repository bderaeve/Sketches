
//BJORN
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };
long previous = 0;

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };

void setup()
{
  /*	
      // Checks if we come from a normal reset or a hibernate reset
      PWR.ifHibernate();

      // When out of hibernate: REDUCED SETUP, disable flag and goto loop()
      if( intFlag & HIB_INT )
      {
          USB.begin();
          xbeeZB.hibernateInterrupt();
          
          previous=millis();
          USB.print("\ntime"); USB.println(previous);
          USB.print("\n");
    
          //RTC.setAlarm1(0,0,0,40, RTC_OFFSET,RTC_ALM1_MODE3); // Sets Alarm1
          //USB.print("Alarm1 ="); USB.println(RTC.getAlarm1());
          
          xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
          xbeeZB.ON();
          xbeeZB.wake(); 
      }
      
      // After powering on the node or hardware reset: FULL SETUP
      else
      {
    */
          USB.begin();
          USB.println("usb started\n");
          
          RTC.setTime("13:04:04:05:15:00:00");
          USB.println(RTC.getTime());
          
        //  RTCUt.setNextTimeWhenToWakeUpViaOffset(4);
    //  }  
}

void loop()
{
      USB.begin();
      USB.println("\ndevice enters loop\n");
      USB.println(freeMemory());

      ////////////////////////////////////////////////
      // 6. Entering hibernate mode
      ////////////////////////////////////////////////
      //xbeeZB.hibernate();
      //xbeeZB.enterLowPowerMode(HIBERNATE, 2);
      //PWR.deepSleep("00:00:00:10", RTC_OFFSET, RTC_ALM1_MODE3, ALL_OFF);
      PWR.sleep(WTD_8S, ALL_OFF);
        if( intFlag & WTD_INT )
        {
          Utils.blinkLEDs(1000);
          Utils.blinkLEDs(1000);
          Utils.blinkLEDs(1000);
          intFlag &= ~(WTD_INT);
        }
}




