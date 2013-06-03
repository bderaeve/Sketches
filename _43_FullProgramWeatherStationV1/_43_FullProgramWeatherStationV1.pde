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

long previous = 0;
#define FM "Free Memory: "

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A };
uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };


void setup()
{
      USB.begin();
      USB.print("usb started, ");  USB.print(FM);    USB.println(freeMemory());
  
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
      if( COMM.setupXBee(panID, ROUTER, gateway, NONE, "NodeD") ) 
          USB.println("\nERROR SETTING UP XBEE MODULE\n");
          
      //xbeeZB.setActiveSensorMask(4, BATTERY, VANE, ANEMO, PLUVIO);
      
      USB.println(RTC.getTime());
      USB.print(FM);   USB.println(freeMemory());
}


void loop()
{
      int er = 0;
      USB.println("\ndevice enters loop");
      USB.print(FM);   USB.println(freeMemory());

      ///////////////////////////////////////////////////////////////////////////
      // 1. MEASURE THE SAMPLES FOUND IN THE NODES ACTIVE SENSOR MASK
      /////////////////////////////////////////////////////////////////////////// 
      
            USB.print("actSensMask ");
            USB.println( (int) xbeeZB.activeSensorMask );
      
          er = SensUtils.measureSensors(xbeeZB.activeSensorMask);
          if( er!= 0)
          {
             USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
             USB.println(er);
          }
      
            USB.println("Sensors measured");
      
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
          *   might be incorrect. However, reduced setup saves about 8 seconds so 
          *   we will use it but test if the node is correctly associated via the 
          *   return value of the send function, which will return an error if the 
          *   node wasn't correctly associated. 
          */
          er = COMM.checkNodeAssociation(LOOP);
          if( er!= 0)
          {
                USB.print("ERROR COMM.checkNodeAssociation(LOOP) returns: ");
                USB.println(er);
          }
          
              USB.println("\nAssociation checked");
      ///////////////////////////////////////////////////////////////////////////
      // 3. SEND THE SENSORS MEASURED IN 1 TO THE GATEWAY
      ///////////////////////////////////////////////////////////////////////////
          if( er != 0 )
          {
              USB.print("\nStoreMeasuredSensors\n");
              SensUtils.storeMeasuredSensorValues(xbeeZB.activeSensorMask); 
          }
          else
          {
              er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
              if( er!= 0)
              {
                   USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
                   USB.println(er);
                   
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
                        USB.print("\n\nFATAL ERROR\n\n"); 
                   }
              }
              else
              {
                   USB.print("\nSensors sent successfully\n");
                   //check if there are older saved values that must be send 
              }
              
              
            ///////////////////////////////////////////////////////////////////////////
            // 4. CHECK FOR COMMANDS / IO_REQUESTS
            ///////////////////////////////////////////////////////////////////////////
            
                er = COMM.receiveMessages(END_DEVICE);
                if( er!= 0)
                {
                    if(er == 1)
                    {
                        USB.print("receiveMessages() returns: nothing received");
                    }
                    else
                    {
                        USB.print("ERROR COMM.receiveMessages() returns: ");
                        USB.println(er);
                    }
                }              
              
              
          }
      

      ///////////////////////////////////////////////////////////////////////////
      // 5. SLEEP / HIBERNATE
      ///////////////////////////////////////////////////////////////////////////
          USB.println("\nStart enter low power mode");
          USB.print(FM);   USB.println(freeMemory());
          PWRUt.enterLowPowerModeWeatherStation(XBEE_SLEEP_ENABLED);
}




