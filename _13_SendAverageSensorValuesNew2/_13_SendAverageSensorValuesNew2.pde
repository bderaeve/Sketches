/*
 *  Explanation: Sending temperature value to coordinator
 */

uint8_t panid[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA};
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A};

//Coordinator MAC address: 0013A2004069737A

packetXBee* paq_sent;  //ptr to an XBee packet
int8_t state=0;
long previous=0;
char aux[200];

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
    
      xbeeZB.setSensorMask(3, TEMPERATURE, BATTERY, HUMIDITY);   
}


void loop()
{
      USB.println("\nDevice enters loop");
      int er = 0;

      er = SensUtils.measureSensors(xbeeZB.sensorMask);
      if( er!= 0)
      {
           USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
           USB.println(er);
      }
      

      er = PAQ.sendMeasuredSensors(dest, xbeeZB.sensorMask);
      if( er!= 0)
      {
           USB.print("ERROR PAQ.sendMeasuredSensors(uint16_t *) returns: ");
           USB.println(er);
      }
      
      /*
      er = SensUtils.measureSensors(xbeeZB.sensorMask);
      if( er!= 0)
      {
           USB.print("ERROR SensUtils.measureSensors(uint16_t *) returns: ");
           USB.println(er);
      }
      
     
      er = PAQ.send_As_IO_Data(dest, PAQ.packetData);
      if( er!= 0)
      {
           USB.print("ERROR PacketUtils.send_As_IO_Data() returns: ");
           USB.print(er); 
      }
      */
      
      
      
      delay(5000);
}






