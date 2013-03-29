/*
 *  Explanation: Selecting which sensors to measure via own API functions (sensorUtils.h) and
 *  send the measured values via own API (PacketUtils.h & CommUtils.h)
 *
 *  Condition: VERY STABLE
 */

//uint8_t panid[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA};
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A};  //Coordinator Bjorn address: 0013A2004069737A
//uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x74}; //Gateway Roel address: 0013A20040697374

//packetXBee* paq_sent;  //ptr to an XBee packet
//int8_t state=0;
//long previous=0;
//char aux[200];


packetXBee* paq_sent;
 int8_t state=0;
 long previous=0;
char * DEST_MAC_ADDRESS = "0013A2004069737A";

void setup()
{
      USB.begin();
      USB.println("PROGRAM: SendAverageTemperature.pde\nUSB port started...");
      
      xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
      xbeeZB.ON();
      xbeeZB.wake();  // For end devices: SM=1!!!
      delay(3000);
      
      // Suppose network parameters are OK!

      // wait until XBee module is associated
      if(COMM.checkNodeAssociation()) USB.println("ERROR CHECKING NODE ASSOCIATION");    
    
    
      /* 
       * Store which sensors are installed on the node:
       * First parameter must be the number of sensors!
       * Choices are: TEMPERATURE, HUMIDITY, PRESSURE, BATTERY, CO2, ANEMO, VANE, PLUVIO
       */
       //xbeeZB.setActiveSensorMask(1, TEMPERATURE);   
       xbeeZB.setActiveSensorMask(3, TEMPERATURE, BATTERY, HUMIDITY);   
}


void loop()
{
      USB.println("\nDevice enters loop");
      int er = 0;
    
/*
      sendMessageLocal("TEST MESSAGE", DEST_MAC_ADDRESS);    //WORKS / HAS WORKED
      delay(1000);
      
      COMM.sendMessageLocalWorking("TEST MESSAGE 2", DEST_MAC_ADDRESS);    //WORKS / HAS WORKED
      delay(1000);
      
      COMM.sendMessage(dest, IO_DATA, "TEST MESSAGE 3");    //WORKS / HAS WORKED
      delay(1000);

      PAQ.testComm(dest, IO_DATA, "TEST MESSAGE 4");    //WORKS / HAS WORKED 
      delay(1000); 
      */
      
      PAQ.testComm2(dest, IO_DATA);
      
      //PAQ.testComm3(dest, IO_DATA, "TEST MESSAGE 1302");  
      delay(1000); 
      
      er = SensUtils.measureSensors(xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
           USB.println(er);
      }
      
   
     /* 
      er = PAQ.sendMeasuredSensors(dest, xbeeZB.activeSensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er);
      }
      */
      
      

     
/* 
      er = COMM.sendMessage(dest, ERRORMESSAGE, "ERROR MESSAGE");
      if( er!= 0)
      {
           USB.print("ERROR COMM.sendMessage");
           USB.println(er);
      }
*/


      
      delay(10000);
}



bool sendMessageLocal(const char * message, const char * destination)
{
      bool error = false;
      paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
      paq_sent->mode=UNICAST;
      paq_sent->MY_known=0;
      paq_sent->packetID=0x52;
      paq_sent->opt=0; 
      xbeeZB.hops=0;
      xbeeZB.setOriginParams(paq_sent, MY_TYPE);
      xbeeZB.setDestinationParams(paq_sent, destination, message, MAC_TYPE, DATA_ABSOLUTE);
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




