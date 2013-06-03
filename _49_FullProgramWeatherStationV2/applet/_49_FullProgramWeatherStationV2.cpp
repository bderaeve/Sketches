/*
 *  Test program for checking the receiving of messages (minimum time2wait)
 *  Use Sketch 29 to send a simple test message.
 *    No sleep on this device!
 *    STATE:  If receiving device is a ROUTER:
 */

//BJORN
//uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
////uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };

#include "WProgram.h"
void setup();
void loop();
int er = 0;
long previous = 0;
#define ret "\n ...RETURNED: "
#define ok "OK\n"

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A };
uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };


void setup()
{
      USB.begin();
      USB.print("usb started, ");  USB.print(FM);    USB.println(freeMemory());
      
      xbeeZB.printStoredErrors();
  
      /* setupXBee(uint8_t[8], DeviceRole, uint8_t[8], SleepMode, char *);
       *   \param 0: PAN ID
       *   \param 1: DEVICE ROLE: END_DEVICE, ROUTER, or COORDINATOR => ZIGBEE SLEEP MODE
       *   \param 2: DEFAULT GATEWAY MAC ADDRESS
       *   \param 3: SLEEPMODE FOR THE WASPMOTE
       *   \param 4: NODE IDENTIFIER (the NI must be a 20 character max string)
       *   \return: 0 : successfully joined and associated
       *	    1 : either XBee not present or no coordinator found, use #define ASSOCIATION_DEBUG
       *   \@post : defaultTime2Wake will be used until an ADD_NODE_REQ and an CH_NODE/SENS_FREQ_REQ is received
       */
      //if( COMM.setupXBee(panID, END_DEVICE, gateway, DEEPSLEEP, "WeatherStation") ) 
      if( COMM.setupXBee(panID, END_DEVICE, gateway, DEEPSLEEP, "WeatherStation", 12, HIGHPERFORMANCE) ) 
          USB.println("\nERROR SETTING UP XBEE MODULE\n");
      USB.println(RTC.getTime());
          
      ///////////////////////////////////////////////////////////////////////////////////////
      // FOR TESTING PURPOSES ONLY:  Overrides the inNetwork boolean!
      //xbeeZB.setActiveSensorMask(3, TEMPERATURE, HUMIDITY, BATTERY);
      //er = xbeeZB.setActiveSensorMaskWithTimes(6, TEMPERATURE, 12, BATTERY, 30, CO2, 30);
      //USB.println(er);
      ///////////////////////////////////////////////////////////////////////////////////////    
}


void loop()
{
      USB.print(FM);   USB.println(freeMemory());
       
      ///////////////////////////////////////////////////////////////////////////
      // 1. MEASURE THE SAMPLES FOUND IN THE NODES ACTIVE SENSOR MASK
      /////////////////////////////////////////////////////////////////////////// 
      
      er = SensUtils.measureSensors(xbeeZB.activeSensorMask);      USB.print(ret);  
                                                                   USB.print(er);
    
      ///////////////////////////////////////////////////////////////////////////
      // 2B. POWER SAVER MODE
      ///////////////////////////////////////////////////////////////////////////
      //if(xbeeZB.powerPlan == POWERSAVER)
      //{
      //    SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask);
      //}     
     
      ///////////////////////////////////////////////////////////////////////////
      // 2B. HIGH PERFORMANCE MODE
      ///////////////////////////////////////////////////////////////////////////       
      //else
      //{    
          /* This function checks if the node's mode is actually HIGHPERFORMANCE or if this
           * mode is only temporarily forced in order to send the sensors saved during a 
           * certain amount of consecutive POWERSAVER cycles. In the latter case this
           * function is also responsible for powering the XBee module.
           */
           //xbeeZB.verifyPowerPlan();        

           ///////////////////////////////////////////////////////////////////////////
           // 2B.1 CHECK IF THE NODE HAS JOINED THE NETWORK
           /////////////////////////////////////////////////////////////////////////// 
              
           /* checkNodeAssociation(LOOP): @see: 'commUtils.h'
            *
            * \return:   0 : OK
            *            1 : NO_PARENT_FOUND
            *            2 : XBEE_NOT_DETECTED_ON_WASPMOTE
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
               case 0:  USB.println(ok);
                        break;
               case 1:  USB.println(1);
                        //SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                        break;
               case 2:  USB.println(2);
                        //SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
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
                      //SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask);                      
                 }
            }    
            
            ///////////////////////////////////////////////////////////////////////////////
            // 2B.2 IF ASSOCIATION OK, TRY TO SEND THE SENSORS MEASURED IN 1 TO THE GATEWAY
            ///////////////////////////////////////////////////////////////////////////////
            if( er == 0 ) // NO ASSOCIATION ERROR
            {
                USB.print("\n\nSENDING: ");
                /* \Returns: 0 : SENT SUCCESSFULLY
                 *           1 : NOT_SENT_DUE_TO_SLEEP
                 *           2 : NOT_SENT_OR_MESSAGE_LOST 
                 *           3 : NOT_EXECUTED_MASK_EMPTY
                 */
                er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
                USB.print(ret); USB.print(er);
                
                if( er!= 0)
                {                   
                     er = COMM.retryJoining();
                     if( er == 0 )
                     {
                          er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
                          if( er!= 0)
                          {
                              xbeeZB.storeError(NODE_FAILED_TO_SEND_THE_MEASURED_SENSORS_AFTER_A_SUCCESSFULL_RETRY_JOINING);
                              //SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                              USB.print("\n\nFATAL ERROR\n\n"); 
                          }                              
                     }
                     else
                     {
                          xbeeZB.inNetwork = false;
                          //SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                     }
                }

                ///////////////////////////////////////////////////////////////////////////
                // 2B.3 ...CHECK FOR COMMANDS / IO_REQUESTS
                ///////////////////////////////////////////////////////////////////////////                    
                if(er == 0) // IF NO SEND ERROR <=> ASSOCIATION STATE WAS CORRECT... 
                {
                     /* Returns: 0 : MESSAGE_RECEIVED_AND_TREATED_SUCCESSFULLY
                      *          1 : NOTHING_RECEIVED
                      *          2 : NOT_EXECUTED
                      *          3 : GOT_INVALID_PACKET_TYPE
                      *          4 : ERROR_WHILE_TREATING_PACKET_,_SENT_TO_GATEWAY
                      *          ? : UNKNOWN
                      */
                     er = COMM.receiveMessages(END_DEVICE);  USB.print(ret);  USB.print(er);
                   
                     ///////////////////////////////////////////////////////////////////////////
                     // 2B.4 ...CHECK IF THERE ARE SAVED SAMPLES THAT MUST BE SEND
                     ///////////////////////////////////////////////////////////////////////////   
                     /*if(xbeeZB.mustSendSavedSensorValues)
                     {
                          USB.print("\n\nSEND SAVED: ");                     USB.print(ret);
                          er = PackUtils.sendStoredSensors(gateway);         USB.println(er);
                          er = PackUtils.sendStoredErrors(gateway);          USB.println(er);
                          xbeeZB.mustSendSavedSensorValues = false;
                     }  */       
                }// close ... IF NO SEND ERROR <=> ASSOCIATION STATE WAS CORRECT...
                  
            }//close ... IF THERE WAS NO ASSOCIATION ERROR
              
      //}//close ... HIGHPERFORMANCE MODE
    
           
      

      ///////////////////////////////////////////////////////////////////////////
      // 5. SLEEP / HIBERNATE
      ///////////////////////////////////////////////////////////////////////////
      USB.print("\nENTERING LOW POWER MODE: ");
      PWRUt.enterLowPowerModeWeatherStation(XBEE_SLEEP_ENABLED);
}





int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

