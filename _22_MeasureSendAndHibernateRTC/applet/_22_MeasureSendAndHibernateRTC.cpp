/*
 *  Test program for enabling and sending different sensors
 *    STATE = stable (it gives transmission error = 2 but does send the correct values)
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

uint16_t sortedTimes[4] = {20, 25, 60, 100};

char * sleepTime = "00:00:00:10";   

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
    
          RTC.setAlarm1(0,0,0,40, RTC_OFFSET,RTC_ALM1_MODE3); // Sets Alarm1
          USB.print("Alarm1 ="); USB.println(RTC.getAlarm1());
          
          xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
          xbeeZB.ON();
          xbeeZB.wake(); 
      }
      
      // After powering on the node or hardware reset: FULL SETUP
      else
      {
          USB.begin();
          USB.println("usb started\n");
      
          if( COMM.setupXBee() ) 
              USB.println("ERROR SETTING UP XBEE MODULE");
          
          // "year:month:date:nrDayOfWeek:hour:minute:second - day 1 = Sunday"
          RTC.setTime("13:04:04:05:15:00:00");
          USB.println(RTC.getTime());
          
          //RTC.setTime("13:04:00:00:00:00:00");
          RTCUt.getTime();
          
          RTCUt.setNextTimeWhenToWakeUpViaOffset(4);
          
          
          //RTC.setTime(13,4,2,2,8,29,0); 
          //USB.print("RTC time = "); 
          //USB.println(RTC.getTime());
          
        
          /*
          //RTC.setAlarm1(0,0,0,30,RTC_OFFSET,RTC_ALM1_MODE2);
          RTC.setAlarm1(0,0,0,50, RTC_OFFSET,RTC_ALM1_MODE3); // Sets Alarm1
          USB.print("\nAlarm1 ="); USB.println(RTC.getAlarm1());
          RTCUt.convertAlarm1ToInt();
          USB.println( (int) RTCUt.Alarm1int );
          
          RTC.setAlarm1(0,0,1,0, RTC_OFFSET,RTC_ALM1_MODE3); // Sets Alarm1
          USB.print("\nAlarm1 ="); USB.println(RTC.getAlarm1());
          RTCUt.convertAlarm1ToInt();
          USB.println( (int) RTCUt.Alarm1int );
          
          RTC.setAlarm1(0,0,10,0, RTC_OFFSET,RTC_ALM1_MODE3); // Sets Alarm1
          USB.print("\nAlarm1 ="); USB.println(RTC.getAlarm1());
          RTCUt.convertAlarm1ToInt();
          USB.println( (int) RTCUt.Alarm1int );
          
          RTC.setAlarm1(0,0,1,10, RTC_OFFSET,RTC_ALM1_MODE3); // Sets Alarm1
          USB.print("\nAlarm1 ="); USB.println(RTC.getAlarm1());
          RTCUt.convertAlarm1ToInt();
          USB.println( (int) RTCUt.Alarm1int );
          
          RTC.setAlarm1(0,1,0,0, RTC_OFFSET,RTC_ALM1_MODE3); // Sets Alarm1
          USB.print("\nAlarm1 ="); USB.println(RTC.getAlarm1());
          RTCUt.convertAlarm1ToInt();
          USB.println( (int) RTCUt.Alarm1int );
          
          RTC.setAlarm1(0,1,1,0, RTC_OFFSET,RTC_ALM1_MODE3); // Sets Alarm1
          USB.print("\nAlarm1 ="); USB.println(RTC.getAlarm1());
          RTCUt.convertAlarm1ToInt();
          USB.println( (int) RTCUt.Alarm1int );
          */
          
          /* param1 = number of sensors to measurePossible input:
           * other params can be: TEMPERATURE, HUMIDITY, PRESSURE, BATTERY, CO2, ANEMO, VANE , PLUVIO
           */    
          xbeeZB.setActiveSensorMask(4, TEMPERATURE, BATTERY, HUMIDITY, PRESSURE);  
      }  
}

void loop()
{
      int er = 0;
      
      er = COMM.checkNodeAssociation(LOOP);
      if( er!= 0)
      {
         USB.print("ERROR COMM.checkNodeAssociation(LOOP) returns: ");
         USB.println(er);
      }
      
      previous=millis();
      USB.print("\ntime\n"); USB.println(previous);
      
      USB.print("\nTimeRTC: ");
      USB.println(RTC.getTime());

      USB.println("\ndevice enters loop\n");

      //xbeeZB.setActiveSensorMask(3, TEMPERATURE, BATTERY, HUMIDITY);  
      xbeeZB.printSensorMask(xbeeZB.activeSensorMask);

      //xbeeZB.createAndSaveNewTime2SleepArray(sortedTimes);
      
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


      ////////////////////////////////////////////////
      // 6. Entering hibernate mode
      ////////////////////////////////////////////////
      xbeeZB.hibernate();
}





int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

