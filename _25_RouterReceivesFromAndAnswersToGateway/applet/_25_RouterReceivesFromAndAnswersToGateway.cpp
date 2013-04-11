/*
 *  ------Waspmote XBee ZigBee Receiving Instructions from Gateway ---------
 *  This mote is configured as a router.
 */
 
 //BJORN
#include "WProgram.h"
void setup();
void loop();
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA };
long previous = 0;

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
    
      xbeeZB.setActiveSensorMask(4, TEMPERATURE, BATTERY, HUMIDITY, PRESSURE);
      xbeeZB.setActiveSensorTimes(4, 30, 20, 50, 100);  
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

      er = PackUtils.sendMeasuredSensors(dest, xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er);
          
      }      
     
      er = COMM.receiveMessages();
      if( er!= 0)
      {
           USB.print("ERROR COMM.receiveMessages() returns: ");
           USB.println(er); 
      }
    
          
      delay(10000);
}


int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

