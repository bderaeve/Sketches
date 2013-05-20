/*
 *  Explanation: Reading temperature value from agriculture board / Weather station
 */

float valueTemp, valueHum, valuePres, valueLDR, valueRadiation;
float valueAnemo, valuePluvio, valueVane;

void setup()
{
      USB.begin();
      USB.println("USB port started...");
      delay(100);
      
      SensorAgrV20.setBoardMode(SENS_ON);
      
      RTC.ON();
}


void loop()
{
      USB.println("Device enters loop");
      
  // Part 1: Sensor reading
      
      // Turn on the sensor and wait for stabilization and response time
      SensorAgrV20.setSensorMode(SENS_ON, SENS_AGR_TEMPERATURE);
      SensorAgrV20.setSensorMode(SENS_ON, SENS_AGR_HUMIDITY);
      SensorAgrV20.setSensorMode(SENS_ON, SENS_AGR_PRESSURE);
      SensorAgrV20.setSensorMode(SENS_ON, SENS_AGR_LDR);
      SensorAgrV20.setSensorMode(SENS_ON, SENS_AGR_RADIATION);
      SensorAgrV20.setSensorMode(SENS_ON, SENS_AGR_ANEMOMETER);
      delay(100);
      
      // Read the temperature sensor 
      valueTemp = SensorAgrV20.readValue(SENS_AGR_TEMPERATURE);
      valueHum = SensorAgrV20.readValue(SENS_AGR_HUMIDITY);
      valuePres = SensorAgrV20.readValue(SENS_AGR_PRESSURE);
      valueLDR = SensorAgrV20.readValue(SENS_AGR_LDR);
      valueRadiation = SensorAgrV20.readValue(SENS_AGR_RADIATION);
          // Conversion from voltage into umol·m-2·s-1
          valueRadiation /= 0.00015;
      valueAnemo = SensorAgrV20.readValue(SENS_AGR_ANEMOMETER);    
      valuePluvio = SensorAgrV20.readValue(SENS_AGR_PLUVIOMETER);
      valueVane = SensorAgrV20.readValue(SENS_AGR_VANE);
          
      // Turn off the sensor
      SensorAgrV20.setSensorMode(SENS_OFF, SENS_AGR_TEMPERATURE);
      SensorAgrV20.setSensorMode(SENS_OFF, SENS_AGR_HUMIDITY);
      SensorAgrV20.setSensorMode(SENS_OFF, SENS_AGR_PRESSURE);
      SensorAgrV20.setSensorMode(SENS_OFF, SENS_AGR_LDR);
      SensorAgrV20.setSensorMode(SENS_OFF, SENS_AGR_RADIATION);
      SensorAgrV20.setSensorMode(SENS_OFF, SENS_AGR_ANEMOMETER);
      
 // Part 2: USB printing
      
      // Print the temperature value through the USB
      USB.print("T = ");     USB.print(valueTemp);      USB.println(" ºC");     
      USB.print("Hum = ");   USB.print(valueHum);       USB.println(" %");
      USB.print("Pres = ");  USB.print(valuePres);      USB.println(" kPa");
      USB.print("Luminosity = ");  USB.print(valueLDR); USB.println(" V");     // Range: 0 - 3,3V
      USB.print("Anemo = "); USB.print(valueAnemo);     USB.println(" km/h");  // Range: 0 ~ 240km/h
      USB.print("Pluvio = ");USB.print(valuePluvio);    USB.println(" mm/min");
      USB.print("Vane = ");  
     // SensorAgrV20.getVaneDirection(valueVane);
          switch(SensorAgrV20.vane_direction)
          {
            case  SENS_AGR_VANE_N   :  USB.println("N");
                                       break;
            case  SENS_AGR_VANE_NNE :  USB.println("NNE");
                                       break;
            case  SENS_AGR_VANE_NE  :  USB.println("NE");
                                       break;
            case  SENS_AGR_VANE_ENE :  USB.println("ENE");
                                       break;
            case  SENS_AGR_VANE_E   :  USB.println("E");
                                       break;
            case  SENS_AGR_VANE_ESE :  USB.println("ESE");
                                       break;
            case  SENS_AGR_VANE_SE  :  USB.println("SE");
                                       break;
            case  SENS_AGR_VANE_SSE :  USB.println("SSE");
                                       break;
            case  SENS_AGR_VANE_S   :  USB.println("S");
                                       break;
            case  SENS_AGR_VANE_SSW :  USB.println("SSW");
                                       break;
            case  SENS_AGR_VANE_SW  :  USB.println("SW");
                                       break;
            case  SENS_AGR_VANE_WSW :  USB.println("WSW");
                                       break;
            case  SENS_AGR_VANE_W   :  USB.println("W");
                                       break;
            case  SENS_AGR_VANE_WNW :  USB.println("WNW");
                                       break;
            case  SENS_AGR_VANE_NW  :  USB.println("WN");
                                       break;
            case  SENS_AGR_VANE_NNW :  USB.println("NNW");
                                       break;
          }      
      
      delay(500);
}


