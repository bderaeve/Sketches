/*
 *  Test program for checking the receiving of messages (minimum time2wait)
 *  Use Sketch 29 to send a simple test message.
 *    No sleep on this device!
 *    STATE:  If receiving device is a ROUTER:
 */

//BJORN
#include "WProgram.h"
void setup();
void loop();
uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };

long previous = 0;
#define FM "Free Memory: "

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A };
//uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };


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
              USB.println(freeMemory());
          
              if( COMM.setupXBee(panID, ROUTER, 0, NONE, "NodeD") ) 
                  USB.println("\nERROR SETTING UP XBEE MODULE\n");
              USB.println(freeMemory());

              USB.println(RTC.getTime());
              USB.println(freeMemory());
              
              /* param1 = number of sensors to measurePossible input:
               * other params can be: TEMPERATURE, HUMIDITY, PRESSURE, BATTERY, CO2, ANEMO, VANE , PLUVIO
               */    
              //xbeeZB.setActiveSensorMask(4, TEMPERATURE, BATTERY, HUMIDITY, PRESSURE);
              //xbeeZB.setActiveSensorMask(1, BATTERY);
    /*
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
*/      }
}

void loop()
{
      int er = 0;
      USB.println("\ndevice enters loop");
      //USB.print(FM);   USB.println(freeMemory());
     
      USB.print("actSensMask ");
      USB.println( (int) xbeeZB.activeSensorMask );
      //USB.print(FM);   USB.println(freeMemory());  // = 1811 B
      er = SensUtils.measureSensors(xbeeZB.activeSensorMask);
      if( er!= 0)
      {
         USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
         USB.println(er);
      }
      //USB.print(FM);   USB.println(freeMemory());  // = 1811 B
      
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
      //USB.print(FM);   USB.println(freeMemory());  // = 1459 B   UPDATE: 2231 B
      
      er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er);
      }
      //USB.print(FM);   USB.println(freeMemory());  // = 1753 B

      er = COMM.receiveMessages();
      if( er!= 0)
      {
          USB.print("ERROR COMM.receiveMessages() returns: ");
          USB.println(er);
      }
      //USB.print(FM);   USB.println(freeMemory());  // = 1103 B

      xbeeZB.enterLowPowerMode(HIBERNATE);
      //USB.print(FM);   USB.println(freeMemory());
      //delay(500);
}





int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

