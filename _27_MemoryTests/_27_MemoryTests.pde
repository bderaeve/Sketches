/*
 *  Test program for checking the available amount of memory
 *    STATE = ok after removing all unnecessary shit from the API
 *            all functions (measure, send, receive) work and have no memory leaks
 */

//BJORN
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x76 };
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA };
long previous = 0;

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };


void setup()
{	
          USB.begin();
          USB.println("usb started\n");
          USB.println(freeMemory());
      
          if( COMM.setupXBee(panID, dest, "Node") ) 
              USB.println("ERROR SETTING UP XBEE MODULE");
          USB.println(freeMemory());
          
          // "year:month:date:nrDayOfWeek:hour:minute:second - day 1 = Sunday"
          RTC.setTime("13:04:04:05:15:00:00");
          USB.println(RTC.getTime());
          USB.println(freeMemory());
          
          /* param1 = number of sensors to measurePossible input:
           * other params can be: TEMPERATURE, HUMIDITY, PRESSURE, BATTERY, CO2, ANEMO, VANE , PLUVIO
           */    
          xbeeZB.setActiveSensorMask(4, TEMPERATURE, BATTERY, HUMIDITY, PRESSURE);
          xbeeZB.setActiveSensorTimes(4, 30, 20, 50, 100);
      
}

void loop()
{
      int er = 0;
      USB.println("\ndevice enters loop");
      USB.println(freeMemory());
      
      //previous=millis();
      //USB.print("\ntime\n"); USB.println(previous);
      
      USB.print("\nTimeRTC: ");
      USB.println(RTC.getTime());
      

      //xbeeZB.createAndSaveNewTime2SleepArray(sortedTimes);
      
      //USB.println("measure");
      //USB.println(freeMemory());  // = 1811 B
      er = SensUtils.measureSensors(xbeeZB.activeSensorMask);
      if( er!= 0)
      {
         USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
         USB.println(er);
      }
      //USB.println(freeMemory());  // = 1811 B
      
      //USB.println("checkAssoc");
      //USB.println(freeMemory());   // = 1459 B  UPDATE: 2231 B
      er = COMM.checkNodeAssociation(LOOP);
      if( er!= 0)
      {
         USB.print("ERROR COMM.checkNodeAssociation(LOOP) returns: ");
         USB.println(er);
      }
      //USB.println(freeMemory());  // = 1459 B   UPDATE: 2231 B
      
      //previous=millis();
      //USB.print("\nEndassociation\n"); USB.println(previous);   
      
      //USB.println("send");
      //USB.println(freeMemory());  // = 1753 B
      er = PackUtils.sendMeasuredSensors(dest, xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er);
      }
      //USB.println(freeMemory());  // = 1753 B
      
      USB.println("receive");
      USB.println(freeMemory());   // = 1103 B
      er = COMM.receiveMessages();
      if( er!= 0)
      {
          USB.print("ERROR COMM.receiveMessages() returns: ");
          USB.println(er);
      }
      USB.println(freeMemory());  // = 1103 B
      
      delay(5000);
}




