packetXBee* paq_sent;
int8_t state=0;
long previous=0;


//BJORN
//uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x77 };     //Node D
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };


//ROEL
uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };


//TEST ADD_NODE_REQ = OK
  unsigned char ar1[2] = {0x00, 0x09};   // mask 9 = TEMPERATURE + BATTERY 

//TEST MASK_REQ = OK  
  // content = ""         

//TEST CH_NODE_FREQ_REQ = OK  
  unsigned char ar2[2] = {0x00, 0x04};        
 
//TEST CH_SENS_FREQ_REQ = 
  unsigned char ar3[4] = {0x00, 0x01, 0x00, 0x04};


void setup()
{
      // setup for Serial port over USB
      USB.begin();
      USB.println("PROGRAM: EndDeviceSendsMessageToRouter\nUSB port started...");
      USB.println(freeMemory());
  
      //if( COMM.setupXBee(panID, gateway, "NodeD") ) 
      if( COMM.setupXBee(panID, ROUTER, gateway, NONE, "NodeC") ) 
          USB.println("\nERROR SETTING UP XBEE MODULE\n");
      USB.println(freeMemory());
}

void loop()
{
      int er = 0;
      USB.println("End Device enters loop");
      
      /* checkNodeAssociation(LOOP): @see: 'commUtils.h'
       *
       * \return:   0 : joined successfully
       *            1 : no XBee present on Waspmote
       *            2 : coordinator not found
       */     
      er = COMM.checkNodeAssociation(LOOP);
      if( er!= 0 )
      {
         USB.print("ERROR COMM.checkNodeAssociation(LOOP) returns: ");
         USB.println(er);
      }     
      
      /* sendMessage(uint8_t *, ApplicationID, char *): @see: 'commUtils.h'
       *
       * \return:   0 : message sent
       *            1 : error_TX = 1
       *            2 : error_TX = 2
       */
       /// TEST ADD_NODE_REQUEST:
         er = COMM.sendMessage(dest, ADD_NODE_REQ, COMM.escapeZeros( (char *) ar1, sizeof(ar1) ));
         
       /// TEST MASK_REQUEST: 
         //er = COMM.sendMessage(dest, MASK_REQ, "");  

       /// TEST CH_NODE_FREQ_REQUEST:
         //er = COMM.sendMessage(dest, CH_NODE_FREQ_REQ, COMM.escapeZeros( (char *) ar2, sizeof(ar2) )); 
 
       /// TEST CH_NODE_FREQ_REQUEST:
          //er = COMM.sendMessage(dest, CH_SENS_FREQ_REQ, COMM.escapeZeros( (char *) ar3, sizeof(ar3) ));         
       if( er!= 0 )
       {
          USB.print("ERROR COMM.sendMessage() returns: ");
          USB.println(er); 
       }       
       
       /*
       er = COMM.sendMessage(dest, MASK_REQ, (char *) ar2);
       if( er!= 0 )
       {
          USB.print("ERROR COMM.sendMessage() returns: ");
          USB.println(er); 
       }
       */
      
       delay(5000);
}
  

