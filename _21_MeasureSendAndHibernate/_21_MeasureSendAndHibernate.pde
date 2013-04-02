/*
 *  Test program for enabling and sending different sensors
 *    STATE = stable (it gives transmission error = 2 but does send the correct values)
 */

//BJORN
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA };

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };

char* sleepTime = "00:00:00:10";   

void setup()
{
      // Checks if we come from a normal reset or a hibernate reset
      PWR.ifHibernate();
      
      // When out of hibernate: REDUCED SETUP, disable flag and goto loop()
      if( intFlag & HIB_INT )
      {
          USB.begin();
          xbeeZB.hibernateInterrupt();
          
          xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
          xbeeZB.ON();
          xbeeZB.wake(); 
      }
      
      // After powering on the node or hardware reset: FULL SETUP
      else
      {
          USB.begin();
          USB.println("usb started\n");
      
          if( COMM.setupXBee(panID) ) 
              USB.println("ERROR SETTING UP XBEE MODULE");
              
          /* param1 = number of sensors to measurePossible input:
           * other params can be: TEMPERATURE, HUMIDITY, PRESSURE, BATTERY, CO2, ANEMO, VANE , PLUVIO
           */    
          xbeeZB.setActiveSensorMask(3, TEMPERATURE, BATTERY, HUMIDITY);  
      }  
}

void loop()
{
      int er = 0;
      USB.println("\ndevice enters loop\n");

      //xbeeZB.setActiveSensorMask(3, TEMPERATURE, BATTERY, HUMIDITY);  
      xbeeZB.printSensorMask(xbeeZB.activeSensorMask);

      er = SensUtils.measureSensors(xbeeZB.activeSensorMask);
      if( er!= 0)
      {
         USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
         USB.println(er);
      }
     
      COMM.checkNodeAssociation();
     
      er = PackUtils.sendMeasuredSensors(dest, xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er);
          
      }


      ////////////////////////////////////////////////
      // 6. Entering hibernate mode
      ////////////////////////////////////////////////
      USB.println("Entering hibernate");
      PWR.hibernate(sleepTime, RTC_OFFSET, RTC_ALM1_MODE2);
}




