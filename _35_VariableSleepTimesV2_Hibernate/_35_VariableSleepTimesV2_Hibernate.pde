/*
 *  Test program for enabling and sending different sensors
 *    STATE = stable (it gives transmission error = 2 but does send the correct values)
 */

//BJORN
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };
long previous = 0;
int er = 0;

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };


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
          USB.begin();
          USB.println("usb started\n");
      
          //if( COMM.setupXBee() )
         if( COMM.setupXBee(panID, dest, HIBERNATE, "nodeD") ) 
              USB.println("ERROR SETTING UP XBEE MODULE");
          
          // "year:month:date:nrDayOfWeek:hour:minute:second - day 1 = Sunday"
          RTC.setTime("13:04:04:05:00:00:00");
          USB.println(RTC.getTime());
          
          //RTC.setTime("15:04:00:00:00:00:00");
          RTCUt.getTime();

          //will also set the first time2sleep offset.
          er = xbeeZB.setActiveSensorMaskWithTimes(6, TEMPERATURE, 2, HUMIDITY, 3, BATTERY, 6);
          if( er != 0 )
          {
               USB.println("ERROR setActSensMWithTimes: ");
               USB.print(er);  
          }
          er = xbeeZB.setDeviceRole(ROUTER);
          er = xbeeZB.getDeviceRole();
          if( er != 0 )
          {
               USB.println("ERROR getDeviceRole: ");
               USB.print(er);   
          }
          else
          USB.print("device role = "); USB.println( (int) xbeeZB.deviceRole );
         
      }  
}

void loop()
{
      USB.println("\ndevice enters loop\n");
      USB.println(RTC.getTime());
      USB.println(freeMemory());
      
      
/*
      USB.print("\nTimeRTC: ");
      USB.println(RTC.getTime());


      //xbeeZB.printSensorMask(xbeeZB.activeSensorMask);

      xbeeZB.createAndSaveNewTime2SleepArray(sortedTimes);
      USB.print("FreeMem"); USB.println(freeMemory());
      
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
      
      USB.print("\nEndassociation\n");
      er = PackUtils.sendMeasuredSensors(dest, xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er); 
      }
      
      USB.print("\ntime at hibernate"); USB.println(RTC.getTime());
*/

      ////////////////////////////////////////////////
      // 6. Entering hibernate mode
      ////////////////////////////////////////////////
      xbeeZB.enterLowPowerMode(HIBERNATE);
}




