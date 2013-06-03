// Define private key to encrypt message  
char * password = "AES passoword"; 
 
// original message on which the algorithm will be applied 
char * message1 = "Libelium"; 


uint16_t size;
uint8_t length; 
 
void setup(){ 
 
  // init USB port 
  USB.begin(); 
  USB.println("ENCRYPTION example"); 
 
} 
 
void loop()
{ 
     USB.println("\n--------------ENCRYPTING MESSAGE 1------------------");
     encryptDecrypt(message1);
     
     
     USB.println("\n--------------ENCRYPTING MESSAGE 2------------------");
     //char * message2 = (char *) calloc(1, sizeof(char));
     //*message2 = (unsigned int) 4;
     //USB.println( (int) *message2 );
     
     encryptDecrypt2(4);
       
     delay(5000); 
} 


void encryptDecrypt(char * message)
{

///////////////////////////////////////////////////////////////////////////////////////////
//    ENCRYPTION
///////////////////////////////////////////////////////////////////////////////////////////
      
    // 1. Caculate block numbers of encrypted message 
    size = AES.sizeOfBlocks(message); 
   
    // 2. Declaration of variable encrypted message 
    uint8_t encrypted_message[size]; 
   
    // 3. Calculate encrypted message with ECB cipher mode and PKCS5 padding. 
    AES.encrypt(128,password,message,encrypted_message,ECB,PKCS5); 
   
    // 4. Printing encrypted message  
    AES.printMessage(encrypted_message,size); 
  
///////////////////////////////////////////////////////////////////////////////////////////
//    DECRYPTION
///////////////////////////////////////////////////////////////////////////////////////////

    //1. Calculate size of encrypted message 
    length = sizeof(encrypted_message); 
    
    //2. Declarete variable to store decrypted messsage 
    uint8_t decrypted_message[100]; 

    //3. Declarate variable to storre original size of  
    //   decrypted message. 
    uint16_t original_size[1]; 
    
    //4. Calculate decrypted message using AES algorithm 
    AES.decrypt(128,password,encrypted_message,length,decrypted_message,original_size,ECB,PKCS5); 
     
    //5. Pritn on USB output decrypted message  
    USB.println(); 
    USB.println(original_size[0],DEC);
    //USB.print("\""); 
    for (uint8_t h=0; h<original_size[0];h++){ 
        USB.print( (char) decrypted_message[h]); 
    } 
    //USB.println("\""); 
  
    //6. Free memory 
    free(decrypted_message); 
}


void encryptDecrypt2(char value)
{

///////////////////////////////////////////////////////////////////////////////////////////
//    ENCRYPTION
///////////////////////////////////////////////////////////////////////////////////////////
      
    // 1. Caculate block numbers of encrypted message 
    size = AES.sizeOfBlocks(&value); 
   
    // 2. Declaration of variable encrypted message 
    uint8_t encrypted_message[size]; 
   
    // 3. Calculate encrypted message with ECB cipher mode and PKCS5 padding. 
    AES.encrypt(128,password,&value,encrypted_message,ECB,PKCS5); 
   
    // 4. Printing encrypted message  
    AES.printMessage(encrypted_message,size); 
  
///////////////////////////////////////////////////////////////////////////////////////////
//    DECRYPTION
///////////////////////////////////////////////////////////////////////////////////////////

    //1. Calculate size of encrypted message 
    length = sizeof(encrypted_message); 
    
    //2. Declarete variable to store decrypted messsage 
    uint8_t decrypted_message[100]; 

    //3. Declarate variable to storre original size of  
    //   decrypted message. 
    uint16_t original_size[1]; 
    
    //4. Calculate decrypted message using AES algorithm 
    AES.decrypt(128,password,encrypted_message,length,decrypted_message,original_size,ECB,PKCS5); 
     
    //5. Pritn on USB output decrypted message  
    USB.println(); 
    USB.println(original_size[0],DEC);
    //USB.print("\""); 
    for (uint8_t h=0; h<original_size[0];h++){ 
        USB.print( (char) decrypted_message[h]); 
    } 
    //USB.println("\""); 
  
    //6. Free memory 
    free(decrypted_message); 
}

