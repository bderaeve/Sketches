/*
 *  Test program for checking the receiving of messages (minimum time2wait)
 *  Use Sketch 29 to send a simple test message.
 *    No sleep on this device!
 *    STATE:  If receiving device is a ROUTER:
 */
 
#include "WProgram.h"
void setup();
void loop();
int er = 0;
long previous = 0;
bool first = true;

//BJORN
uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };
//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A };


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
          //RTC.ON();
          USB.println("usb started\n");
          USB.println(freeMemory());
      
          //if( COMM.setupXBee(panID, END_DEVICE, 0, HIBERNATE, "NodeD") )
          if( COMM.setupXBee(panID, ROUTER, 0, NONE, "NodeD") ) 
              USB.println("\nERROR SETTING UP XBEE MODULE\n");
                    
          // "year:month:date:nrDayOfWeek:hour:minute:second - day 1 = Sunday"
          RTC.setTime("13:04:04:05:00:00:00");
          USB.print("\nTime: ");
          USB.println(RTC.getTime());
          
          /* param1 = number of sensors to measurePossible input:
           * other params can be: TEMPERATURE, HUMIDITY, PRESSURE, BATTERY, CO2, ANEMO, VANE , PLUVIO
           */    
          xbeeZB.setActiveSensorMask(3, TEMPERATURE, BATTERY, HUMIDITY);
          // xbeeZB.setActiveSensorMask(1, BATTERY);
          //xbeeZB.setActiveSensorTimes(4, 30, 20, 50, 100);
      }
      
}

void loop()
{
      USB.println("\ndevice enters loop");
      USB.println(freeMemory());
      
      USB.print("\nactSensMask =");
      USB.println( (int) xbeeZB.activeSensorMask );
      USB.print("\n");
      
      er = SensUtils.measureSensors(xbeeZB.activeSensorMask);
      if( er!= 0)
      {
         USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
         USB.println(er);
      }
      
      /* checkNodeAssociation(LOOP): @see: 'commUtils.h'
       *
       * \return:   0 : joined successfully
       *            1 : no XBee present on Waspmote
       *            2 : coordinator not found
       */
      er = COMM.checkNodeAssociation(LOOP);
      if( er!= 0)
      {
         USB.print("ERROR COMM.checkNodeAssociation(LOOP) returns: ");
         USB.println(er);
      }
      
      er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er);
      }
      else USB.print("\nSend sensors OK\n");
      
      //USB.println(freeMemory());  // = 1753 B
      
      USB.print("receive, free mem: ");
      USB.println(freeMemory());   // = 1103 B

      if(first)
      {
          er = COMM.receiveMessages();
          if( er!= 0)
          {
              USB.print("ERROR COMM.receiveMessages() returns: ");
              USB.println(er);
          }
         first = false;
      }
      
      USB.print("\n");
      USB.println(freeMemory());  // = 1103 B
      
      if(xbeeZB.deviceRole == END_DEVICE)
        xbeeZB.enterLowPowerMode(HIBERNATE);
      else
        delay(500);
}





int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

