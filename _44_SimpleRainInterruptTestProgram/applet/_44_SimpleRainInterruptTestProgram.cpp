/*  
 * Test program to see if the rain interrupt works when no other objects (gasses board) are created
 * 
 */


#include <WaspSensorAgr_v20.h>

// Variable to store the number of anemometer pulses
#include "WProgram.h"
void setup();
void loop();
long pluviometerCounter = 0;

// Variable to store the precipitations value
float pluviometer;

void setup()
{
      // Turn on the USB and print a start message
      USB.begin();
      USB.println("usb started\nTest rain interrupt program\n");
      delay(100);
    
      // Turn on the sensor board
      //SensorAgrV20.ON();
      SensorAgrV20.setBoardMode(SENS_ON);
      delay(100);
      
      // Turn on the RTC
      RTC.ON();
      delay(100);
}
 
void loop()
{
      // Part 1: Enabling Pluviometer Interruptions and sleeping
      SensorAgrV20.sleepAgr("00:00:00:30", RTC_OFFSET, RTC_ALM1_MODE3,UART0_OFF | UART1_OFF | BAT_OFF | RTC_OFF, SENS_AGR_PLUVIOMETER);
    
      // Pluviometer interruptions detached
      SensorAgrV20.detachPluvioInt();
      
      // Part 2: After wake up update and print the rainfall detected
    
      // Turn on the USB
      USB.begin();
      
      // Process the interruption received
      if( intFlag & PLV_INT)
      {
          USB.println("Pluviometer interruption arrived");
          pluviometerCounter++;
      }
      else if(intFlag & RTC_INT)
      {
          USB.println("RTC interruption arrived");
      }
    
      // Convert the number of interruptions received into mm of rain
      pluviometer = float(pluviometerCounter) * 0.2794;  
      
      // Print the accumulated rainfall
      USB.print("Accumulated rainfall: ");
      USB.print(pluviometer);
      USB.println("mm");
    
      // Clearing the interruption flag before coming back to sleep
      clearIntFlag();
}

int main(void)
{
	init();

	setup();
    
	for (;;)
		loop();
        
	return 0;
}

