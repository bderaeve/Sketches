/*
 *  Test program to check: 
 *    - where the avr compiler puts consts
 *    - if USB.println leaks memory somehow?
 */


/**  Case 1:  Doing almost nothing
 **           Program size: 2836 bytes
 **           Free memory @ setup: 7486
 **                       @ device enters loop: 7486
 **  Case 2:  Extra function with USB.println("strings") in WaspXBeeZBnode.cpp, not calling the function
 **           Program size: 2836 bytes
 **           Free memory @ setup: 7484
 **                       @ device enters loop: 7484
 **  Case 3:  Calling the extra function:
 **           Program size: 12996 bytes
 **           Free memory @ setup: 5493  -= veeel
 **                       @ device enters loop: 5493
 **                       @ in function: 5489
 **                       @ after function: 5493 => no memory leaks in USB.println
 **  Case 4:  2nd Extra function: 
 **           Program size: 13000 bytes += 4 bytes  /  13002 bytes += 2bytes
 **           Free memory @ setup: 5489 -= 4bytes   /   5487 bytes -= 2bytes
 **                       @ in loop: 5485 -= 4bytes /   5483 bytes -= 2bytes
 **    !!! BUT I am never calling this function !!!
 **  Case 5:  Calling only 2nd Extra function:
 **
 **
 **
 **
 **
 */
void setup()
{	
          USB.begin();
          USB.println("usb started\n");
          USB.println(freeMemory());    
}

void loop()
{
      USB.println("\ndevice enters loop");
      USB.println("before: ");
      USB.println(freeMemory());
      
      //xbeeZB.testMemory3();
      
      
      //xbeeZB.testMemory();
      xbeeZB.testMemory2();
      USB.println("after:");
      USB.println(freeMemory());
            
      delay(5000);
}




