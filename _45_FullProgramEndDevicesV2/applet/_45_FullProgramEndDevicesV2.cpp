/*
 *  Second version of the full program for Waspmote 'End Devices'.
 *  
 */
 
 
// !!!! @PRECONDITION: PUT #define WEATHER_STATION in 'BjornClasses.h' in COMMENT !!!! 

//BJORN
//uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
////uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };
#include "WProgram.h"
void setup();
void loop();
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };

int er = 0;
int comm_error = 0;
long previous = 0;
#define ret "\n ...RETURNED: "

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A };
uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };


void setup()
{
      // Checks if we come from a normal reset or a hibernate reset
      PWR.ifHibernate();
    
      // When out of hibernate: REDUCED SETUP, disable flag and goto loop()
      if( intFlag & HIB_INT )
      {
          USB.begin();
          xbeeZB.hibernateInterrupt();
      }
      
      // After powering on the node or hardware reset: FULL SETUP
      else
      {
          USB.begin();
          USB.print("usb started, ");  USB.print(FM);   USB.println(freeMemory());
      
          xbeeZB.printStoredErrors();
          
         /* Initialize the program:
          *   \param 0: PAN ID < uint8_t[8] >
          *   \param 1: DEVICE ROLE < END_DEVICE; ROUTER; COORDINATOR >
          *     \@note: For END_DEVICES using ZigBee sleep mode, also the XBee must be configured as end device.
  	  *   \param 2: DEFAULT GATEWAY MAC ADDRESS < uint8_t[8] >
  	  *   \param 3: WASPMOTE SLEEPMODE < SLEEP; DEEPSLEEP; HIBERNATE; NONE >
  	  *   \param 4: NODE IDENTIFIER < a char[20] max string >
          *   \param 5: DEFAULT SLEEPING TIME < uint16_t >
          *     \@note: 10s = 1 ; E.g. 6 = 1min; 30 = 5min; 31 = 5min 10s; 360 = 1h; 8640 = 1day; ...
          *   \param 6: POWER PLAN < HIGHPERFORMANCE; POWERSAVER >
  	  *   \@post  : In case no parent was found the error 'ERROR_SETTING_UP_XBEE_MODULE' will be
  	  *	        saved to EEPROM. This error will be sent to the gateway when the XBee finds
          *             a parent OR it will be printed to the Libelium terminal when an installer 
          *             plugs in the node.
  	  *   \return : 0 : successfully joined and associated
  	  *	        1 : either XBee not present or no coordinator found, use #define ASSOCIATION_DEBUG
          */
          if( COMM.setupXBee(panID, END_DEVICE, gateway, DEEPSLEEP, "NodeD", 6, HIGHPERFORMANCE) ) 
              USB.println("\nERROR SETTING UP XBEE MODULE\n");
          USB.println(RTC.getTime());
          
          ///////////////////////////////////////////////////////////////////////////////////////
          // FOR TESTING PURPOSES ONLY:  overrides the inNetwork boolean!
          xbeeZB.setActiveSensorMask(3, TEMPERATURE, HUMIDITY, BATTERY);
          //er = xbeeZB.setActiveSensorMaskWithTimes(6, TEMPERATURE, 12, BATTERY, 30, CO2, 30);
          //USB.println(er);
          ///////////////////////////////////////////////////////////////////////////////////////      
      }
}


void loop()
{
    ///////////////////////////////////////////////////////////////////////////
    // 1. MEASURE THE SAMPLES FOUND IN THE NODES ACTIVE SENSOR MASK
    /////////////////////////////////////////////////////////////////////////// 
    er = SensUtils.measureSensors(xbeeZB.activeSensorMask);     USB.print(ret);
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
    // 2A. POWER SAVER MODE
    ///////////////////////////////////////////////////////////////////////////
    if(xbeeZB.powerPlan == POWERSAVER)
    {
        SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask);
    }
        
    ///////////////////////////////////////////////////////////////////////////
    // 2B. HIGH PERFORMANCE MODE
    ///////////////////////////////////////////////////////////////////////////       
    else
    {
        /* This function checks if the node's mode is actually HIGHPERFORMANCE or if this
         * mode is only temporarily forced in order to send the sensors saved during a 
         * certain amount of consecutive POWERSAVER cycles. In the latter case this
         * function is also responsible for powering the XBee module.
         */
         xbeeZB.verifyPowerPlan();
    
         ///////////////////////////////////////////////////////////////////////////
         // 2B.1 CHECK IF THE NODE HAS JOINED THE NETWORK
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
          er = COMM.checkNodeAssociation(LOOP);   USB.print(ret);
          switch(er)
          {
             case 0:  USB.print("OK\n");
                      break;
             case 1:  USB.print("NO_PARENT_FOUND\n");
                      SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                      break;
             case 2:  USB.print("XBEE_NOT_DETECTED_ON_WASPMOTE\n");
                      SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                      break;
          }

          if( er!= 0)
          {    
              /* This function will redo the full XBee setup. In case the result is not
               * successfull, the function will store an error in EEPROM. Otherwise, a warning
               * will be send to the gateway, indicating a low RSSI. */
               er = COMM.retryJoining();
               if( er != 0 )
               {
                    xbeeZB.inNetwork = false;
                    SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask);                      
               }
          }                      
      
          ///////////////////////////////////////////////////////////////////////////////
          // 2B.2 IF ASSOCIATION OK, TRY TO SEND THE SENSORS MEASURED IN 1 TO THE GATEWAY
          ///////////////////////////////////////////////////////////////////////////////
          if( er == 0 ) // NO ASSOCIATION ERROR
          {
              USB.print("\n\nSENDING: ");
              er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
              USB.print(ret);
              switch(er)
              {
                 case 0:  USB.print("OK\n");
                          break;
                 case 1:  USB.print("NOT_SENT_DUE_TO_SLEEP\n");
                          break;
                 case 2:  USB.print("NOT_SENT_OR_MESSAGE_LOST\n");
                          break;
                 case 3:  USB.print("NOT_EXECUTED_MASK_EMPTY_?");
                          break;
              }
 
 
              if( er!= 0)
              {                   
                   er = COMM.retryJoining();
                   if( er == 0 )
                   {
                        er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
                        if( er!= 0)
                        {
                            xbeeZB.storeError(NODE_FAILED_TO_SEND_THE_MEASURED_SENSORS_AFTER_A_SUCCESSFULL_RETRY_JOINING);
                            SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                            USB.print("\n\nFATAL ERROR\n\n"); 
                        }                              
                   }
                   else
                   {
                        xbeeZB.inNetwork = false;
                        SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                   }
              }                 
             
              ///////////////////////////////////////////////////////////////////////////
              // 2B.3 ...CHECK FOR COMMANDS / IO_REQUESTS
              ///////////////////////////////////////////////////////////////////////////                    
              if(er == 0) // IF NO SEND ERROR <=> ASSOCIATION STATE WAS CORRECT... 
              {
                   er = COMM.receiveMessages(END_DEVICE);  USB.print(ret);
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
                 
                   ///////////////////////////////////////////////////////////////////////////
                   // 2B.4 ...CHECK IF THERE ARE SAVED SAMPLES THAT MUST BE SEND
                   ///////////////////////////////////////////////////////////////////////////   
                   if(xbeeZB.mustSendSavedSensorValues)
                   {
                        er = PackUtils.sendStoredSensors(gateway);
                        xbeeZB.mustSendSavedSensorValues = false;
                   }         
              }// close ... IF NO SEND ERROR <=> ASSOCIATION STATE WAS CORRECT...
                
          }//close ... IF THERE WAS NO ASSOCIATION ERROR
            
    }//close ... HIGHPERFORMANCE MODE
      
             
    ///////////////////////////////////////////////////////////////////////////
    // 3. SLEEP / HIBERNATE
    ///////////////////////////////////////////////////////////////////////////
    USB.print("\nENTERING LOW POWER MODE: ");
    PWRUt.enterLowPowerMode( (SleepMode) xbeeZB.sleepMode );
}





int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

