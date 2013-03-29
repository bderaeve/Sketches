/*
 *  Explanation: Selecting which sensors to measure via own API functions (sensorUtils.h) and
 *  send the measured values via own API (PacketUtils.h & CommUtils.h)
 *
 *  Condition: VERY STABLE
 */

//uint8_t panid[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA};
#include "WProgram.h"
void setup();
void loop();
void hibInterrupt();
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A};  //Coordinator Bjorn address: 0013A2004069737A
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74}; //Gateway Roel address: 0013A20040697374


char* sleepTime = "00:00:00:10";   

void setup()
{
      PWR.ifHibernate();
  
      USB.begin();
      USB.println("PROGRAM: SendAverageTemperature.pde\nUSB port started...");
      
      xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
      xbeeZB.ON();
      xbeeZB.wake();  // For end devices: SM=1!!!
      delay(3000);
      
      // Suppose network parameters are OK!

      // wait until XBee module is associated
      if(COMM.checkNodeAssociation()) USB.println("ERROR CHECKING NODE ASSOCIATION");    
}


void loop()
{
      Utils.blinkLEDs(1000);
      USB.println("\nDevice enters loop");
     
      // If Hibernate has been captured, execute the associated function
      if( intFlag & HIB_INT )
      {
          hibInterrupt();
      }
      
      if(COMM.checkNodeAssociation()) USB.println("ERROR CHECKING NODE ASSOCIATION"); 
 
      //xbeeZB.convertTime2Wait2Char(12);
      
      USB.println("Entering hibernate");
      PWR.hibernate(sleepTime, RTC_OFFSET, RTC_ALM1_MODE2);

  
}

void hibInterrupt()
{
      USB.println("Out of hibernate (interrupt)");
      Utils.blinkLEDs(1000);
      Utils.blinkLEDs(1000);
      intFlag &= ~(HIB_INT);
}




int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

