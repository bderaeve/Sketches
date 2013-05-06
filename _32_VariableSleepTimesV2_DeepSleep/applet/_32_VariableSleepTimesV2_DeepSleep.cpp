

//BJORN
#include "WProgram.h"
void setup();
void loop();
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };
long previous = 0;
int er = 0;

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };

void setup()
{
          USB.begin();
          USB.println("usb started\n");
      
          //if( COMM.setupXBee() )
         if( COMM.setupXBee(panID, dest, DEEPSLEEP, "nodeD") ) 
              USB.println("ERROR SETTING UP XBEE MODULE");
          
          // "year:month:date:nrDayOfWeek:hour:minute:second - day 1 = Sunday"
          RTC.setTime("13:04:04:05:15:00:00");
          USB.println(RTC.getTime());
          
          //RTC.setTime("15:04:00:00:00:00:00");
          RTCUt.getTime();
          
          //will also set the first time2sleep offset.
          er = xbeeZB.setActiveSensorMaskWithTimes(6, TEMPERATURE, 4, HUMIDITY, 5, BATTERY, 10);
          if( er != 0 )
          {
               USB.println("ERROR setActSensMWithTimes: ");
               USB.print(er);  
          }
}

void loop()
{
      USB.println("\ndevice enters loop\n");
      USB.println(RTC.getTime());
      USB.println(freeMemory());
       

      ////////////////////////////////////////////////
      // 6. Entering hibernate mode
      ////////////////////////////////////////////////
      xbeeZB.enterLowPowerMode(DEEPSLEEP);
}





int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

