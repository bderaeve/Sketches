packetXBee* paq_sent;
int8_t state=0;
long previous=0;
char*  data="Message count:  \r\n";

//BJORN
uint8_t gateway[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x77 };    //Node D
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };



//ROEL
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74 };  //Gateway Roel address: 0013A20040697374
//uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAB };


//Destination (Router D) MAC address
//char * DEST_MAC_ADDRESS = "0013A20040697377";
//int  i = 0;


void setup()
{
      // setup for Serial port over USB
      USB.begin();
      USB.println("PROGRAM: EndDeviceSendsMessageToRouter\nUSB port started...");
      USB.println(freeMemory());
  
      if( COMM.setupXBee(panID, gateway, "NodeD") ) 
          USB.println("ERROR SETTING UP XBEE MODULE");
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
       unsigned char ar[3] = {0x01, 0x03, 0};
      er = COMM.sendMessage(dest, ADD_NODE_REQ, (char *) ar);
      if( er!= 0 )
      {
         USB.print("ERROR COMM.sendMessage() returns: ");
         USB.println(er); 
      }
      
      delay(5000);
}
  

/*
bool sendMessage(const char * message, const char * destination)
{
      bool error = false;
      paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
      paq_sent->mode=UNICAST;
      paq_sent->MY_known=0;
      paq_sent->packetID=0x52;
      paq_sent->opt=0; 
      xbeeZB.hops=0;
      xbeeZB.setOriginParams(paq_sent, "0013A20040697379", MY_TYPE);
      xbeeZB.setDestinationParams(paq_sent, destination, data, MAC_TYPE, DATA_ABSOLUTE);
      xbeeZB.sendXBee(paq_sent);
      USB.print("start printing xbeeZB.error_TX:");
      USB.println(xbeeZB.error_TX);// print xbeeZB.error_TX
      if( !xbeeZB.error_TX )
      {
          //XBee.println("ok");
          USB.println("End device sends out a challenge ok");
          Utils.setLED(LED1, LED_ON);   // Ok, blink green LED
          delay(500);
          Utils.setLED(LED1, LED_OFF);
          error = false;
      }
      else
      { 
          USB.println("challenge transmission error\n\n");
          Utils.setLED(LED0, LED_ON);   // Error, blink red LED
          delay(500);
          Utils.setLED(LED0, LED_OFF);
          error = true;
      }
      free(paq_sent);
      paq_sent=NULL;
      return error;
} 

/*
void waitingAnswer()
{
    // Waiting for 10 sec on the answer
    previous=millis();
    while( (millis()-previous) < 10000 )
    {
          if( XBee.available() )
          {
                xbeeZB.treatData();
                USB.println("waiting for the reply and printing xbeeZB.error_RX:");
                USB.println(xbeeZB.error_RX);// print xbeeZB.error_RX
                if( !xbeeZB.error_RX ) 
                {
                      // Writing the parameters of the packet received
                      while(xbeeZB.pos>0)
                      {
                            USB.println("Enter xbeeZB.pos ");
                            USB.print("MAC Address Source: ");        
                            for(int b=0;b<4;b++)
                            {
                              //XBee.print(xbeeZB.packet_finished[xbeeZB.pos-1]->macSH[b],HEX);
                              USB.print(xbeeZB.packet_finished[xbeeZB.pos-1]->macSH[b],HEX);
                            }
                            for(int c=0;c<4;c++)
                            {
                              //XBee.print(xbeeZB.packet_finished[xbeeZB.pos-1]->macSL[c],HEX);
                              USB.print(xbeeZB.packet_finished[xbeeZB.pos-1]->macSL[c],HEX);
                            }
                            USB.println("");
                            USB.print("MAC Address Origin: ");            
                            for(int d=0;d<4;d++)
                            {
                              //XBee.print(xbeeZB.packet_finished[xbeeZB.pos-1]->macOH[d],HEX);
                              USB.print(xbeeZB.packet_finished[xbeeZB.pos-1]->macOH[d],HEX);
                            }
                            for(int e=0;e<4;e++)
                            {
                              //XBee.print(xbeeZB.packet_finished[xbeeZB.pos-1]->macOL[e],HEX);
                              USB.print(xbeeZB.packet_finished[xbeeZB.pos-1]->macOL[e],HEX);
                            }
                            USB.println("");
                            USB.print("Data: ");          
                            for(int f=0;f<xbeeZB.packet_finished[xbeeZB.pos-1]->data_length;f++)
                            {
                              //XBee.print(xbeeZB.packet_finished[xbeeZB.pos-1]->data[f],BYTE);
                              USB.print(xbeeZB.packet_finished[xbeeZB.pos-1]->data[f],BYTE);
                            }
                            //XBee.println("");
                            USB.println("");
                            free(xbeeZB.packet_finished[xbeeZB.pos-1]);
                            xbeeZB.packet_finished[xbeeZB.pos-1]=NULL;
                            xbeeZB.pos--;
                      }
                      previous=millis();
                }
          }
    }
}
*/

