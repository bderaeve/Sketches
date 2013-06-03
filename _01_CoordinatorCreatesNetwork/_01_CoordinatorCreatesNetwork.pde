///////////////////////////////////////////////////////////////////////////////////////
/////////////////// DESIGN OF A WIRELESS SENSOR NETWORKING TEST-BED /////////////////// 
///////////////////  BY BJORN DERAEVE AND ROEL STORMS, 2012 - 2013  ///////////////////
///////////////////////////////////////////////////////////////////////////////////////
//                                                                                   //
//   TEST PROGRAM 01: CoordinatorCreatesNetwork                                      //
//    This program sets up a coordinator to initialize a new network                 //
//    If joined devices have error_TX = 1 or 2, check if they have the same          //
//    operating CHANNEL as the coordinator!                                          //
//   Result: Everything works fine                                                   //
//                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////

/**************************************************
* IMPORTANT: Beware of the CHANNEL selected by the 
* coordinator because routers are not able to scan 
* both 0x19 and 0x1A channels
**************************************************/

// coordinator's 64-bit PAN ID to set
//////////////////////////////////////////////////////////////////
uint8_t  PANID[8]={0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xAA};
//////////////////////////////////////////////////////////////////

void setup()
{
    // Init USB 
    USB.begin();
    USB.println("ZB_01 example / Coordinator creates network");
    
    // Inits the XBee ZigBee library
    xbeeZB.init(ZIGBEE,FREQ2_4G,NORMAL);
    
    // Powers XBee
    xbeeZB.ON();
  
    delay(1000);
  
    // set PANID
    xbeeZB.setPAN(PANID);
      
    // check at command flag
    if( xbeeZB.error_AT == 0 ) 
    {
      USB.println("PANID set OK");
    }else{
      USB.println("Error while setting PANID");
    }
  
    // save values
    xbeeZB.writeValues();
  
    // wait for the module to set the parameters
    delay(10000);
}



void loop()
{
    // get network parameters 
    xbeeZB.getOperating16PAN();
    xbeeZB.getOperating64PAN();
    xbeeZB.getChannel();
  
    USB.print("operating 16-bit PAN: ");
    USB.printHex(xbeeZB.operating16PAN[0]);
    USB.printHex(xbeeZB.operating16PAN[1]);
    USB.println();
  
    USB.print("operating 64-bit PAN: ");
    USB.printHex(xbeeZB.operating64PAN[0]);
    USB.printHex(xbeeZB.operating64PAN[1]);
    USB.printHex(xbeeZB.operating64PAN[2]);
    USB.printHex(xbeeZB.operating64PAN[3]);
    USB.printHex(xbeeZB.operating64PAN[4]);
    USB.printHex(xbeeZB.operating64PAN[5]);
    USB.printHex(xbeeZB.operating64PAN[6]);
    USB.printHex(xbeeZB.operating64PAN[7]);
    USB.println();
  
    USB.print("channel: ");
    USB.printHex(xbeeZB.channel);
    USB.println();
  
    delay(3000);
}


