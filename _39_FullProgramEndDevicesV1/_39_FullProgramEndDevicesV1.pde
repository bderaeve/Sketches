/*
 *  Test program for checking the receiving of messages (minimum time2wait)
 *  Use Sketch 29 to send a simple test message.
 *    No sleep on this device!
 *    STATE:  If receiving device is a ROUTER:
 */
 
 
// !!!! @PRECONDITION: PUT #define WEATHER_STATION in 'BjornClasses.h' in COMMENT !!!! 

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
          
              if( COMM.setupXBee(panID, ROUTER, gateway, HIBERNATE, "NodeD") ) 
                  USB.println("\nERROR SETTING UP XBEE MODULE\n");
              USB.println(freeMemory());

              USB.println(RTC.getTime());
              USB.println(freeMemory());
          }
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
          if( er!= 0)
          {
                USB.print("ERROR COMM.checkNodeAssociation(LOOP) returns: ");
                USB.println(er);
          }
          
  
      ///////////////////////////////////////////////////////////////////////////
      // 3. SEND THE SENSORS MEASURED IN 1 TO THE GATEWAY
      ///////////////////////////////////////////////////////////////////////////
          if( er != 0 )
          {
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
                   //check if there are older saved values that must be send 
              }
          }


      ///////////////////////////////////////////////////////////////////////////
      // 4. CHECK FOR COMMANDS / IO_REQUESTS
      ///////////////////////////////////////////////////////////////////////////
      
          er = COMM.receiveMessages(END_DEVICE);
          switch(er)
          {
             case 0:  USB.print("\nMessage received and treated successfully\n");
                      break;
             case 1:  USB.print("\nNo messages received\n");
                      break;
             case 2:  USB.print("\nERROR: receiveMessages NOT EXECUTED\n");
                      break;
             case 3:  USB.print("\nReceived invalid packet type\n");
                      break;
             case 4:  USB.print("\nError while treating packet, sent to gateway\n");
                      break;
             default: USB.print("\nUNKNONW ERROR IN RECEIVE\n");
                      break;
          }     

      ///////////////////////////////////////////////////////////////////////////
      // 5. SLEEP / HIBERNATE
      ///////////////////////////////////////////////////////////////////////////
 
          PWRUt.enterLowPowerMode();
}




