/*
 *  Test program for checking the receiving of messages (minimum time2wait)
 *  Use Sketch 29 to send a simple test message.
 *    No sleep on this device!
 *    STATE:  If receiving device is a ROUTER:
 */

//BJORN
//uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };

long previous = 0;
#define FM "Free Memory: "

//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0A };
//uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };


void setup()
{
      USB.begin();
      USB.println("usb started\n");
      USB.println(freeMemory());
  
      if( COMM.setupXBee(panID, ROUTER, 0, NONE, "NodeD") ) 
          USB.println("\nERROR SETTING UP XBEE MODULE\n");
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
          er = PackUtils.sendMeasuredSensors(gateway, xbeeZB.activeSensorMask);
          if( er!= 0)
          {
               USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
               USB.println(er);
          }


      ///////////////////////////////////////////////////////////////////////////
      // 4. CHECK FOR COMMANDS / IO_REQUESTS UNTIL NEXT MEASUREMENT
      ///////////////////////////////////////////////////////////////////////////
      
          er = COMM.receiveMessages(ROUTER);
          if( er!= 0)
          {
              USB.print("ERROR COMM.receiveMessages() returns: ");
              USB.println(er);
          }
}




