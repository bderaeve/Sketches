/*
 *  Test program for enabling and sending different sensors
 *    STATE = stable (it gives transmission error = 2 but does send the correct values)
 */

//BJORN
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x05,0x16 };
long previous = 0;

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };

uint16_t sortedTimes[4] = {20, 25, 60, 100};

char* sleepTime = "00:00:01:00";   

void setup()
{	
     
          USB.begin();
          previous=millis();
          USB.print("\ntime"); USB.println(previous);
          USB.print("\n");
          
          xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
          xbeeZB.ON();
          xbeeZB.wake(); 
          
          if( COMM.setupXBee(panID) ) 
              USB.println("ERROR SETTING UP XBEE MODULE");
    
    /*
          int er = 0;
      
          er = COMM.checkNodeAssociation(LOOP);
          if( er!= 0)
          {
             USB.print("ERROR COMM.checkNodeAssociation(LOOP) returns: ");
             USB.println(er);
          }
    */
      /*
          if( COMM.setupXBee() ) 
              USB.println("ERROR SETTING UP XBEE MODULE");
      */ 
          // "year:month:date:nrDayOfWeek:hour:minute:second - day 1 = Sunday"
          RTC.setTime("13:04:04:05:15:00:00");
          //RTC.setTime(13,4,2,2,8,29,0); 
          
  
      
}

void loop()
{

      
}




