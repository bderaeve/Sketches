/*
 *  Explanation: Sending average sensor values to Router/Coordinator
 *  Remarks: Tested and verified on 20/03/2013
 *    -Association after hibernate always works (correct PAN and Channel), 
 *    -Works with Router and End Devices 
 *    -Never xbeeZB.error_TX = 2 ==> STABLE
 *    -The statement (libelium-dev) that "You must remove the jumper the first time you execute your code after uploading it.
 *      After that, you shall have the jumper removed from its place as long as you have this code inside Waspmote
 *      (You would need to put it again in order to upload new codes). Until that, you can switch off and on Waspmote in 
 *      order to see that following times it works perfect."
 *          = NOT TRUE!!!
 *          Sometimes after reconnecting the battery the program will on setup() and you must insert and remove 
 */

uint8_t panid[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA};

/*
float temperatures[10];  // T
char tempStr[5];
float humidities[10];    // H
float pressures[10];     // P
char pressureStr[10];
float CO2;               // C
int battery_level[10]; // B = battery
*/

packetXBee* paq_sent;  //ptr to an XBee packet
int8_t state=0;
long previous=0;
char aux[200];
char* sleepTime = "00:00:00:10";   


void setup()
{
      //RTC.ON();
      // Checks if we come from a normal reset or a hibernate reset
      PWR.ifHibernate();
      
      
      USB.begin();
      USB.println("PROGRAM: SendAverageTemperature.pde\nUSB port started...");
      
      xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
      xbeeZB.ON();
      xbeeZB.wake();  // For end devices: SM=1!!!
      delay(3000);
      

      /* Suppose network parameters are OK! (However: MUST BE DONE IN ORDER TO COME IN VALID ASSOCIATION STATE AFTER SLEEP)
      if(!xbeeZB.setPAN(panid)) USB.println("setPAN ok");
      else USB.println("setPAN error");
    
      if(!xbeeZB.setScanningChannels(0xFF,0xFF)) USB.println("setScanningChannels ok");
      else USB.println("setScanningChannels error");
    
      if(!xbeeZB.setDurationEnergyChannels(3)) USB.println("setDurationEnergyChannels ok");
      else USB.println("setDurationEnergyChannels error");
    
      if(!xbeeZB.getAssociationIndication()) USB.println("getAssociationIndication ok");
      else USB.println("getAssociationIndication error");
    
      xbeeZB.writeValues();
      */
      
      // wait until XBee module is associated
      checkAssociation();
}


void loop()
{
      Utils.blinkLEDs(1000);
      
      // If Hibernate has been captured, execute the associated function
      if( intFlag & HIB_INT )
      {
          hibInterrupt();
      }
      
      USB.println("Device enters loop");
      
      measureSensors();
      
      printCurrentNetworkParams();
      
      sendMessage(aux);
      
      // 5.9 Communication module to OFF
      //xbeeZB.OFF();
      //delay(100);
      
      ////////////////////////////////////////////////
      // 6. Entering hibernate mode
      ////////////////////////////////////////////////
      USB.println("Entering hibernate");
      PWR.hibernate(sleepTime, RTC_OFFSET, RTC_ALM1_MODE2);
}

void hibInterrupt()
{
      USB.println("Out of hibernate (interrupt)");
      Utils.blinkLEDs(1000);
      Utils.blinkLEDs(1000);
      intFlag &= ~(HIB_INT);
}


void measureSensors()
{
      USB.println("void measureSensors()");
      
      // 1. Turn on the sensor board
      SensorGasv20.ON();
      SensorGasv20.setBoardMode(SENS_ON);
      
      // 2. Turn on the RTC
      //RTC.ON();
      
      // 3. Stabilization delay
      delay(100);
      
      // 4. Turn on sensors
      SensorGasv20.setSensorMode(SENS_ON, SENS_TEMPERATURE);
      SensorGasv20.setSensorMode(SENS_ON, SENS_HUMIDITY);
      SensorGasv20.setSensorMode(SENS_ON, SENS_PRESSURE);
      SensorGasv20.configureSensor(SENS_CO2, 1);
      SensorGasv20.setSensorMode(SENS_ON, SENS_CO2);
      
      // 5. Read sensors
      
          /* TEMPERATURE SENSOR:   RANGE: -40° -> +125° */
          measureTemperature();
          
          /* HUMIDITY SENSOR:   RANGE: 0 -> 100% */
          measureHumidity();   
          
          /* ATMOSPHERIC PRESSURE SENSOR:   RANGE: 15 -> 115 kPa */
          //measureAtmPressure();
          
          /* CO2 SENSOR:   RANGE: 350 -> 10 000 ppm 
             normal outdoor level: 350 - 450 ppm; acceptable levels: < 600 ppm */
          //measureCO2();
          
          /* BATTERY LEVEL: 0 - 100% */
          measureBatteryLevel();
          
          USB.print("Average temperature is: ");
          USB.println(temperatures[0]);
          
          //sprintf(aux, "T:%d", (int) temperatures[0] );
          //USB.print("aux: ");
          //USB.println(aux);
          
          Utils.float2String(temperatures[0], tempStr, 1);
          Utils.float2String(pressures[0], pressureStr, 2);
          //USB.print(aux2);
          //sprintf(aux, "T1:%d T2:%s", (int) temperatures[0], aux2);
          sprintf(aux, "T%sH%dP%sC%dB%d", tempStr, (int) humidities[0], pressureStr, (int) CO2, battery_level[0]);
          USB.print("aux: ");
          USB.println(aux);
              

      // 6. Turn of the sensor board
      SensorGasv20.OFF();
      
      // 7. Get time
      RTC.getTime(); 
}

void measureTemperature()
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
}

void measureHumidity()
{
      for (int i=0;i<10;i++)
      {
          humidities[i] = SensorGasv20.readValue(SENS_HUMIDITY);
          delay(100);
      }
      
      // Calculate average (stored in first member of array)
      for (int i=1; i<10; i++) 
      {
          humidities[0] = humidities[0] + humidities[i];
      }
      humidities[0] = humidities[0] / 10 ;  
      USB.print("measureHumidity(): ");
      USB.println(humidities[0]);
}

void measureAtmPressure()
{
      for (int i=0;i<10;i++)
      {
          pressures[i] = SensorGasv20.readValue(SENS_PRESSURE);
          delay(100);
      }
      
      // Calculate average (stored in first member of array)
      for (int i=1; i<10; i++) 
      {
          pressures[0] = pressures[0] + pressures[i];
      }
      pressures[0] = pressures[0] / 10 ;  
      USB.print("measureAtmPressure() :");
      USB.println(pressures[0]);
}

void measureCO2()
{
      previous = millis();
      while (millis() - previous < 30000)
      {
            // dummy readings in order to warm the sensor
            SensorGasv20.readValue(SENS_CO2);    
      }
      CO2 = SensorGasv20.readValue(SENS_CO2);  
      CO2 *= 1000;
      USB.print("measureCO2() ");
      USB.println(CO2);
}

void measureBatteryLevel()
{
      for (int i=0;i<10;i++)
      {
          battery_level[i] = PWR.getBatteryLevel();   // battery_level contains the % of remaining battery
          delay(100);
      }
      
      // Calculate average (stored in first member of array)
      for (int i=1; i<10; i++) 
      {
          battery_level[0] = battery_level[0] + battery_level[i];
      }
      battery_level[0] = battery_level[0] / 10 ;
      USB.print("measureBatteryLevel(): ");
      USB.println(battery_level[0]);  
}

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


void checkAssociation()
{
      xbeeZB.getAssociationIndication();
      while(xbeeZB.associationIndication != 0)
      {
            USB.println("\n\n-----> not associated <----------");
            printCurrentNetworkParams();
            //Utils.setLED(LED0, LED_ON);   // Error, blink red LED 
            delay(12000);
            //Utils.setLED(LED0, LED_OFF);    
            xbeeZB.getAssociationIndication();
            printAssociationState();
      }
      Utils.setLED(LED0, LED_ON);   // OK, blink green LED 
      delay(2000);
      Utils.setLED(LED0, LED_OFF);   
      printCurrentNetworkParams();  
}

void printCurrentNetworkParams()
{
      USB.print("operatingPAN: ");            // get operating PAN ID 
      xbeeZB.getOperatingPAN();
      USB.print(xbeeZB.operatingPAN[0],HEX);
      USB.println(xbeeZB.operatingPAN[1],HEX);
    
      USB.print("extendedPAN: ");              // get operating 64-b PAN ID 
      xbeeZB.getExtendedPAN();
      USB.print(xbeeZB.extendedPAN[0],HEX);
      USB.print(xbeeZB.extendedPAN[1],HEX);
      USB.print(xbeeZB.extendedPAN[2],HEX);
      USB.print(xbeeZB.extendedPAN[3],HEX);
      USB.print(xbeeZB.extendedPAN[4],HEX);
      USB.print(xbeeZB.extendedPAN[5],HEX);
      USB.print(xbeeZB.extendedPAN[6],HEX);
      USB.println(xbeeZB.extendedPAN[7],HEX);
    
      USB.print("channel: ");
      xbeeZB.getChannel();
      USB.println(xbeeZB.channel,HEX);  
}


void printAssociationState()
{
    switch(xbeeZB.associationIndication)
    {
          case 0x00  :  USB.println("Successfully formed or joined a network");
                        break;
          case 0x21  :  USB.println("Scan found no PANs");
                        break;   
          case 0x22  :  USB.println("Scan found no valid PANs based on current SC and ID settings");
                        break;   
          case 0x23  :  USB.println("Valid Coordinator or Routers found, but they are not allowing joining (NJ expired)");
                        break;   
          case 0x24  :  USB.println("No joinable beacons were found");
                        break;   
          case 0x25  :  USB.println("Unexpected state, node should not be attempting to join at this time");
                        break;
          case 0x27  :  USB.println("Node Joining attempt failed");
                        break;
          case 0x2A  :  USB.println("Coordinator Start attempt failed");
                        break;
          case 0x2B  :  USB.println("Checking for an existing coordinator");
                        break;
          case 0x2C  :  USB.println("Attempt to leave the network failed");
                        break;
          case 0xAB  :  USB.println("Attempted to join a device that did not respond.");
                        break;
          case 0xAC  :  USB.println("Secure join error  :  network security key received unsecured");
                        break;
          case 0xAD  :  USB.println("Secure join error  :  network security key not received");
                        break;
          case 0xAF  :  USB.println("Secure join error  :  joining device does not have the right preconfigured link key");
                        break;
          case 0xFF  :  USB.println("Scanning for a ZigBee network (routers and end devices)");
                        break;
          default    :  USB.println("Unkown associationIndication");
                        break;
    }
}
