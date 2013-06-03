///////////////////////////////////////////////////////////////////////////////////////
/////////////////// DESIGN OF A WIRELESS SENSOR NETWORKING TEST-BED /////////////////// 
///////////////////  BY BJORN DERAEVE AND ROEL STORMS, 2012 - 2013  ///////////////////
///////////////////////////////////////////////////////////////////////////////////////
//                                                                                   //
//   TEST PROGRAM 32: VariableSleepTimesV2_DeepSleep                                 //
//      Program developed to debug the variable sleep time functions                 //
//      Result: Everything works fine                                                //
//              result32A.png, result32B.png                                         //
//                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////

uint8_t dest[8] = { 0x00,0x13,0xA2,0x00,0x40,0x69,0x73,0x7A };  //Coordinator Bjorn address: 0013A2004069737A
uint8_t panID[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x0B };
uint8_t gateway[8] = { 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00 };
int er = 0;

void setup()
{
          USB.begin();
          USB.print("usb started, ");  USB.print(FM);   USB.println(freeMemory());
      
         if( COMM.setupXBee(panID, END_DEVICE, gateway, DEEPSLEEP, "NodeD", 6, HIGHPERFORMANCE) ) 
              USB.println("ERROR SETTING UP XBEE MODULE");
          USB.println(RTC.getTime());

          //will also set the first time2sleep offset.
          er = xbeeZB.setActiveSensorMaskWithTimes(6, TEMPERATURE, 4, HUMIDITY, 5, BATTERY, 10);
          if( er != 0 )
          {
               USB.println("ERROR setActSensMWithTimes: ");
               USB.print(er);  
          }
}

void loop()
{
      PWRUt.enterLowPowerMode( (SleepMode) xbeeZB.sleepMode );
}




