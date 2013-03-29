float Sensor=0;

void setup()
{
  USB.begin();
  
  SensorGas.setBoardMode(SENS_ON);delay(1000);
  SensorGas.configureSensor(SENS_CO2,1);
  SensorGas.setSensorMode(SENS_ON, SENS_CO2);
}

void loop(){
  
  delay(30000);
  
  Sensor = SensorGas.readValue(SENS_CO2);
  USB.println(Sensor);
  Sensor=0;
  
}  
