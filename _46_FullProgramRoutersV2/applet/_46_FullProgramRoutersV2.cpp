/*
 *  Test program for checking the receiving of messages (minimum time2wait)
 *  Use Sketch 29 to send a simple test message.
 *    No sleep on this device!
 *    STATE:  If receiving device is a ROUTER:
 */

//BJORN
//uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
#include "WProgram.h"
void setup();
void loop();
uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };

long previous = 0;

#define FM "Free Memory: "
#define ret "\n ...RETURNED: "

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A };
//uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };


void setup()
{
      USB.begin();
      USB.print("usb started, ");  USB.print(FM);   USB.println(freeMemory());
      
      xbeeZB.printStoredErrors();
  
      if( COMM.setupXBee(panID, ROUTER, gateway, NONE, "NodeD", 6, HIGHPERFORMANCE) ) 
          USB.println("\nERROR SETTING UP XBEE MODULE\n");        //ALSO_SAVED_IN_EEPROM
          
      ///////////////////////////////////////////////////////////////////////////////////////
      // FOR TESTING PURPOSES ONLY:  Overrides the inNetwork boolean!          
      xbeeZB.setActiveSensorMaskWithTimes(6, TEMPERATURE, 6, HUMIDITY, 12, BATTERY, 18);   
      xbeeZB.posInArray = 0;
      xbeeZB.setAlarmForRouter(); 
      ///////////////////////////////////////////////////////////////////////////////////////        
}


void loop()
{
      int er = 0;
      USB.print("\ndevice enters loop, "); USB.print(FM);   USB.println(freeMemory());

      ///////////////////////////////////////////////////////////////////////////
      // 1. MEASURE THE SAMPLES FOUND IN THE NODES ACTIVE SENSOR MASK
      /////////////////////////////////////////////////////////////////////////// 
      
          
          er = SensUtils.measureSensors(xbeeZB.activeSensorMask);
          USB.print("AT: "); USB.println(RTC.getTime());
          USB.print(ret);
          switch(er)
          {
             case 0:  USB.print("OK\n");
                      break;
             case 1:  USB.print("MASK_EMPTY\n");
                      break;
             case 2:  USB.print("NOT_EXECUTED\n");
                      break;
          } 
      
      
      ///////////////////////////////////////////////////////////////////////////
      // 2. CHECK IF THE NODE HAS JOINED THE NETWORK
      /////////////////////////////////////////////////////////////////////////// 
      
         /* checkNodeAssociation(LOOP): @see: 'commUtils.h'
          *
          * \return:   0 : joined successfully
          *            1 : no XBee present on Waspmote
          *            2 : coordinator not found
          *
          * \note: after reduced setup (hibernate) the resulting association state 
          *   might be incorrect. However, reduced setup saves about 8 minutes so 
          *   we will use it but test if the node is correctly associated via the 
          *   return value of the send function, which will return an error if the 
          *   node wasn't correctly associated. 
          */
          er = COMM.checkNodeAssociation(LOOP);
          USB.print(ret);
          switch(er)
          {
             case 0:  USB.print("OK\n");
                      break;
             case 1:  USB.print("NO_PARENT_FOUND\n");                //ALSO_SAVED_IN_EEPROM
                      SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                      break;
             case 2:  USB.print("XBEE_NOT_DETECTED_ON_WASPMOTE\n");  //ALSO_SAVED_IN_EEPROM
                      SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                      break;
          }  
  
  
      ///////////////////////////////////////////////////////////////////////////
      // 3. SEND THE SENSORS MEASURED IN 1 TO THE GATEWAY
      ///////////////////////////////////////////////////////////////////////////     
          if( !er )
          {
              er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
              USB.print(ret);
              switch(er)
              {
                 case 0:  USB.print("OK\n");
                          break;
                 case 1:  USB.print("NOT_SENT_DUE_TO_SLEEP\n");    //ALSO_SAVED_IN_EEPROM
                          break;
                 case 2:  USB.print("NOT_SENT_OR_MESSAGE_LOST\n"); //ALSO_SAVED_IN_EEPROM
                          break;
                 case 3:  USB.print("NOT_EXECUTED_MASK_EMPTY_?");  //SENT_TO_XBEE
                          break;
              }   
              if( er!= 0)
              {                   
                   er = COMM.retryJoining();
                   if( er == 0 )
                   {
                        er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
                   }
                   else
                   {
                        xbeeZB.inNetwork = false;
                        SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                   }
                   
                   if( er!= 0)
                   {
                        USB.print("\n\nFATAL ERROR\n\n"); // //SAVED_IN_EEPROM
                   }
              }
              else if(er == 0) 
              {
                
                  //check if there are older saved values that must be send 
                  
                  ///////////////////////////////////////////////////////////////////////////
                  // 4. CHECK FOR COMMANDS / IO_REQUESTS UNTIL NEXT MEASUREMENT
                  ///////////////////////////////////////////////////////////////////////////
                  
                     /* receiveMessages(DeviceRole): @see: 'commUtils.h'
                      * \param: ROUTER: this will make the node check for messages until an 
                      *    RTC interrupt is received. For the first call this alarm is set via 
                      *    'COMM.setupXBee' and will be set to the next measurement time in this 
                      *    call. 
                      *    After the interrupt is received the program restarts at the beginning
                      *    of loop().
                      */
                      USB.print("\n\nRECEIVING AT: ");  USB.print(RTC.getTime()); 
                      USB.print(" UNTIL: ");  USB.print(RTC.getAlarm1());
                      er = COMM.receiveMessages(ROUTER);
                      USB.print(ret);
                      switch(er)
                      {
                         case 0:  USB.print("MESSAGE_RECEIVED_AND_TREATED_SUCCESSFULLY\n");
                                  break;
                         case 1:  USB.print("NOTHING_RECEIVED\n");
                                  break;
                         case 2:  USB.print("NOT_EXECUTED\n");
                                  break;
                         case 3:  USB.print("GOT_INVALID_PACKET_TYPE\n");
                                  break;
                         case 4:  USB.print("ERROR_WHILE_TREATING_PACKET_,_SENT_TO_GATEWAY\n");
                                  break;
                         default: USB.print("UNKNONW_ERROR_\n");
                                  break;
                      }
             }
       }
       else
       {
           er = COMM.retryJoining();
           if( er != 0 )
               USB.print("\n\nFATAL_ERROR\n\n");
       }  
}





int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

