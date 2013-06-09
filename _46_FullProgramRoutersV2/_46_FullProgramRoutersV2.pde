///////////////////////////////////////////////////////////////////////////////////////
/////////////////// DESIGN OF A WIRELESS SENSOR NETWORKING TEST-BED /////////////////// 
///////////////////  BY BJORN DERAEVE AND ROEL STORMS, 2012 - 2013  ///////////////////
///////////////////////////////////////////////////////////////////////////////////////
//                                                                                   //
//   FINAL PROGRAM 46: FullProgramEndRoutersV2                                       //
//      Program developed to run on 'Routers', not allowing sleep modes, using RTC   //
//      alarms if sensors have to be measured.                                       //
//      @PRECONDITION: PUT #define WEATHER_STATION in 'BjornClasses.h' in COMMENT!   // 
//      Result: STABLE                                                               //
//                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////
 
int er = 0;
#define ret "\n ...RETURNED: "
#define ok "OK\n"

//BJORN
//uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
//uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };

//GROUP T
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };     //Gateway Roel address: 0013A20040697374
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A };
uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };


void setup()
{
      USB.begin();
      USB.print("usb started, ");  USB.print(FM);   USB.println(freeMemory());
      
      xbeeZB.printStoredErrors();
  
      if( COMM.setupXBee(panID, ROUTER, gateway, NONE, "NodeD", 6, HIGHPERFORMANCE) ) 
          USB.println("\nERROR SETTING UP XBEE MODULE\n");        //ALSO_SAVED_IN_EEPROM
          USB.println(RTC.getTime());
          
      ///////////////////////////////////////////////////////////////////////////////////////
      // FOR TESTING PURPOSES ONLY:  Overrides the inNetwork boolean!          
      xbeeZB.setActiveSensorMaskWithTimes(6, TEMPERATURE, 6, HUMIDITY, 12, BATTERY, 18);   
      xbeeZB.posInArray = 0;
      xbeeZB.setAlarmForRouter(); 
      ///////////////////////////////////////////////////////////////////////////////////////        
}


void loop()
{
      USB.print(FM);   USB.println(freeMemory());  
      ///////////////////////////////////////////////////////////////////////////
      // 1. MEASURE THE SAMPLES FOUND IN THE NODES ACTIVE SENSOR MASK
      /////////////////////////////////////////////////////////////////////////// 
      /* \return: 1 : Measured successfully
       *          2 : MASK_EMPTY
       *          3 : NOT_EXECUTED
       */
      er = SensUtils.measureSensors(xbeeZB.activeSensorMask);     USB.print(ret); 
                                                                  USB.print(er);     
      
      ///////////////////////////////////////////////////////////////////////////
      // 2. CHECK IF THE NODE HAS JOINED THE NETWORK
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
             case 0:  USB.print(ok);
                      break;
             case 1:  USB.print(1);
                      SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                      break;
             case 2:  USB.print(2);
                      SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
                      break;
          } 
  
  
      ///////////////////////////////////////////////////////////////////////////
      // 3. SEND THE SENSORS MEASURED IN 1 TO THE GATEWAY
      ///////////////////////////////////////////////////////////////////////////     
      if( er == 0 )
      {
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
          // 4. CHECK FOR COMMANDS / IO_REQUESTS UNTIL NEXT MEASUREMENT
          ///////////////////////////////////////////////////////////////////////////          
          
          if(er == 0) 
          {
             /* receiveMessages(DeviceRole): @see: 'commUtils.h'
              * \param: ROUTER: this will make the node check for messages until an 
              *    RTC interrupt is received. For the first call this alarm is set via 
              *    'COMM.setupXBee' and will be set to the next measurement time in this 
              *    call. 
              *    After the interrupt is received the program restarts at the beginning
              *    of loop().
              * Returns: 0 : MESSAGE_RECEIVED_AND_TREATED_SUCCESSFULLY
              *          1 : NOTHING_RECEIVED
              *          2 : NOT_EXECUTED
              *          3 : GOT_INVALID_PACKET_TYPE
              *          4 : ERROR_WHILE_TREATING_PACKET_,_SENT_TO_GATEWAY
              *          ? : UNKNOWN
              */              
              USB.print("\n\nRECEIVING AT: ");  USB.print(RTC.getTime()); 
              USB.print(" UNTIL: ");  USB.print(RTC.getAlarm1());
              er = COMM.receiveMessages(ROUTER);   USB.print(ret);   USB.print(er);
              
              if(xbeeZB.mustSendSavedSensorValues)
              {
                   //er = PackUtils.sendStoredSensors(gateway);
                   er = PackUtils.sendStoredErrors(gateway);          USB.println(er);
                   xbeeZB.mustSendSavedSensorValues = false;
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




