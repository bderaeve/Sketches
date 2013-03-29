/*
 *  Explanation: Measure the sensors and store them in 1 or 2 bytes as HEX value
 *  State:  STABLE  (values are correct!)
 */

#include "WProgram.h"
void setup();
void loop();
void measureSensors();
bool sendMessage(const char * message);
uint8_t panid[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA};
uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A}; //Coordinator Bjorn address: 0013A2004069737A

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
}


void loop()
{
      USB.println("Device enters loop");
      
      measureSensors();
      
      //SensUtils.measureSensors(2, TEMPERATURE, BATTERY);
      
            
      sendMessage("Test messagesssssssssssssssssssssssssssss");
      
      //COMM.sendMessage(dest, IO_DATA, "BLABLABLAKABLAB");
      //sendMessage(aux);
      
      // 5.9 Communication module to OFF
      //xbeeZB.OFF();
      //delay(100);
    
    
      ////////////////////////////////////////////////
      // 6. Entering Deep Sleep mode
      ////////////////////////////////////////////////
      //USB.println(F("Going to sleep..."));
      //USB.println();
      //PWR.deepSleep(sleepTime, RTC_OFFSET, RTC_ALM1_MODE1, ALL_OFF);
    
      //USB.ON();
      //USB.println(F("wake"));
      
      delay(5000);
}


void measureSensors()
{
      USB.println("void measureSensors()");
      
      // 1. Turn on the sensor board
      SensorGasv20.ON();
      SensorGasv20.setBoardMode(SENS_ON);
      
      // 2. Turn on the RTC
      RTC.ON();
      
      // 3. Stabilization delay
      delay(100);
      
      // 4. Turn on and read sensors
      SensUtils.measureBattery();

      SensUtils.measureTemperature();
      SensUtils.measureHumidity();
      SensUtils.measurePressure();
      //SensUtils.measureCO2();
   
      
      // 5. Turn off the sensor board
      SensorGasv20.OFF();
      
      // 6. Print values:
      if(!SensUtils.sensorValue2Chars(SensUtils.temperature, TEMPERATURE))
      { 
          USB.print("Temp float: "); USB.println(SensUtils.temperature);
          USB.print("Temp temp[0]: "); USB.println( (int) SensUtils.temp[0] );
          USB.print("Temp temp[1]: "); USB.println( (int) SensUtils.temp[1] );
          
          int t = ( ((unsigned int) SensUtils.temp[0] )*256) + SensUtils.temp[1];
          USB.print("Temp after reconstruction: "); USB.println( (int) t );
      } else {
          USB.println("Error converting TEMPERATURE sensorValue2Chars");
      }

      if(!SensUtils.sensorValue2Chars(SensUtils.humidity, HUMIDITY))
      { 
          USB.print("Hum float: "); USB.println(SensUtils.humidity);
          USB.print("Hum hum: "); USB.println( (int) SensUtils.hum );
      } else {
          USB.println("Error converting HUMIDITY sensorValue2Chars");
      }      
 
      if(!SensUtils.sensorValue2Chars(SensUtils.pressure, PRESSURE))
      { 
          USB.print("Pressure float: "); USB.println(SensUtils.pressure);
          USB.print("Pres pres[0]: "); USB.println( (int) SensUtils.pres[0] );
          USB.print("Pres Pres[1]: "); USB.println( (int) SensUtils.pres[1] );
          
          //int t = ( ((unsigned int) SensUtils.pres[0] )*256) + SensUtils.pres[1];
          USB.print("Pres after reconstruction: "); 
          USB.println( (long int)  ( ((unsigned int) SensUtils.pres[0]*256) + SensUtils.pres[1] ) );
      } else {
          USB.println("Error converting PRESSURE sensorValue2Chars");
      }
/*
      if(!SensUtils.sensorValue2Chars(SensUtils.co2, CO2))
      { 
          USB.print("co_2 float: "); USB.println(SensUtils.co2);
          USB.print("co_2 co_2[0]: "); USB.println( (int) SensUtils.co_2[0] );
          USB.print("co_2 co_2[1]: "); USB.println( (int) SensUtils.co_2[1] );
          
          int t = ( ((unsigned int) SensUtils.co_2[0] )*256) + SensUtils.co_2[1];
          USB.print("co_2 after reconstruction: "); USB.println( (int) t );
      } else {
          USB.println("Error converting CO2 sensorValue2Chars");
      }
*/
 
      if(!SensUtils.sensorValue2Chars(SensUtils.battery, BATTERY))
      { 
          USB.print("Battery uint16: "); USB.println((long int) SensUtils.battery);
          USB.print("Battery bat: "); USB.println( (int) SensUtils.bat );
      } else {
          USB.println("Error converting BATTERY sensorValue2Chars");
      }          
      
          //char str[20];
          //Utils.float2String(SensUtils.temperature, str, 10);
          //USB.println(str);
          //measureTemperature2();
          
          /* HUMIDITY SENSOR:   RANGE: 0 -> 100% */
          //SensUtils.measureHumidity(); 
          //USB.print("Hum: ");
          //USB.println(SensUtils.humidity);  
          
          /* ATMOSPHERIC PRESSURE SENSOR:   RANGE: 15 -> 115 kPa */
          //SensUtils.measurePressure();
          
          /* CO2 SENSOR:   RANGE: 350 -> 10 000 ppm 
             normal outdoor level: 350 - 450 ppm; acceptable levels: < 600 ppm */
          //SensUtils.measureCO2();
          //USB.print("CO2: "); USB.println(SensUtils.co2);
          
          //sprintf(aux, "T:%d", (int) temperatures[0] );
          //USB.print("aux: ");
          //USB.println(aux);

          
          //Utils.float2String(temperatures[0], tempStr, 0);
          //Utils.float2String(pressures[0], pressureStr, 2);
          
          //uint8_t hex = Utils.str2hex(tempStr);
          //Utils.hex2str(&hex, tempStr, 2);
          //USB.print("uint8_t temp HEX: ");
          
          //USB.print("tempStr: ");
          //USB.println(temp);
          
          //USB.print(aux2);
          //sprintf(aux, "T1:%d T2:%s", (int) temperatures[0], aux2);
          //sprintf(aux, "T%xH%dP%sC%dB%d", (int) temperatures[0], (int) humidities[0], pressureStr, (int) CO2, PWR.getBatteryLevel());
          //USB.print("aux: ");
          //USB.println(aux);
      
      // 7. Get time
      RTC.getTime(); 
}

/*
void measureTemperature2()
{
      for (int i=0;i<10;i++)
      {
          temperatures[i] = SensorGasv20.readValue(SENS_TEMPERATURE);
          delay(100);
      }
      
      // Calculate average (stored in first member of array)
      for (int i=1; i<10; i++) 
      {
          temperatures[0] = temperatures[0] + temperatures[i];
      }
      
      temperatures[0] = temperatures[0] / 10 ;
      USB.print("measureTemperature(): ");
      USB.println(temperatures[0]);  
      
      temperatures[0] += 40;
      temperatures[0] *= 10;
      unsigned int temp = (unsigned int) temperatures[0];
      USB.print("temp after +40, *10, & cast to int = ");
      USB.println((int)temp); 
      //int size = sizeof(int);
      //USB.println(size);
      
      temperature[0] = temp/256; //(temp & 0xFF00)>>8;
      temperature[1] = temp%256; //temp & 0x00FF;
      
      USB.println((int)temperature[0]);
      USB.println((int)temperature[1]);
      USB.println((int)temperature[0]*256);
      
      temp = ( ((unsigned int) temperature[0] )*256 ) + temperature[1];
      USB.print("temp after reconstruction = ");
      USB.println((int)temp);  
      
    SensUtils.blink(1000);
        
}
*/




bool sendMessage(const char * message)
{
      bool error = false;
      paq_sent=(packetXBee*) calloc(1,sizeof(packetXBee)); 
      paq_sent->mode=UNICAST;
      paq_sent->MY_known=0;
      paq_sent->packetID=0x52;
      paq_sent->opt=0; 
      xbeeZB.hops=0;
      xbeeZB.setOriginParams(paq_sent, "5678", MY_TYPE);
      xbeeZB.setDestinationParams(paq_sent, "0013A2004069737A", message, MAC_TYPE,DATA_ABSOLUTE); //gateway mac address: 0013A2004069737A
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




int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

