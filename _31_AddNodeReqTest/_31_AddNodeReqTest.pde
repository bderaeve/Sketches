packetXBee* paq_sent;
int8_t state=0;
long previous=0;


//BJORN
uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x77 };     //Node D
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };


//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };


//Destination (Router D) MAC address
//char * DEST_MAC_ADDRESS = "0013A20040697377";
//int  i = 0;


unsigned char ar1[2] = {0x00, 0x07};         //TEST ADD_NODE_REQ = OK
//unsigned char ar2[3] = {0x00, 0x00, 0};    //TEST MASK_REQ = ?


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
       //COMM.escapeZeros( (char *) ar1, sizeof(ar1) );
       
       uint8_t size = 0;
       size = sizeof(ar1)/sizeof(char);
       USB.print("size = ");
       USB.println( (int) size );
       
       //er = COMM.sendMessage(dest, ADD_NODE_REQ, (char *) ar1);
       er = COMM.sendMessage(dest, ADD_NODE_REQ, COMM.escapeZeros( (char *) ar1, sizeof(ar1) ));
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
  

