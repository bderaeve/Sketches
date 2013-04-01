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



void setup()
{
 
      USB.begin();
      USB.println("usb started\n");
  
      USB.println(freeMemory());

      if( COMM.setupXBee(panID) ) 
          USB.println("ERROR SETTING UP XBEE MODULE");
          
      /* \param1 = number of sensors to measurePossible input:
       * \other params can be: TEMPERATURE, HUMIDITY, PRESSURE, BATTERY, CO2, ANEMO, VANE , PLUVIO
       */    
      xbeeZB.setActiveSensorMask(3, TEMPERATURE, BATTERY, HUMIDITY);       
}

void loop()
{
      int er = 0;
      USB.println("device enters loop\n");
    
      delay(1000);
     
      PackUtils.testPrinting();
      SensUtils.testPrinting();
      COMM.testPrinting();
      xbeeZB.testPrinting();
     
      er = SensUtils.measureSensors(xbeeZB.activeSensorMask);
      if( er!= 0)
      {
         USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
         USB.println(er);
      }
     
     
      er = PackUtils.sendMeasuredSensors(dest, xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er);
          
      }
      
      USB.print("freeMem");
      USB.println(freeMemory());
}


