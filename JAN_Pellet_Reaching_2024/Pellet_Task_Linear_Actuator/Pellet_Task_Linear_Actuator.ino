/* Pellet Task Linear Actuator
 Irina Morozov 
 May 23, 2024
*/
//initialize variables
int mode = -1;
const int relay1 = 6;   //Arduino pin that triggers relay #1
const int relay2 = 7;   //Arduino pin that triggers relay #2

//Include the Wire library, to allow communication with I2C devices
#include <Wire.h>
//Pins used on the Arduino Uno
//SDA(data line) is only the A4 pin
//SCL(clock line) is only the A5 pin

void setup() {
  
  //Set pinMode to OUTPUT for the two relay pins
  pinMode(relay1, OUTPUT);
  pinMode(relay2, OUTPUT);
 
  // initialize serial communication at 9600 bps:
  Serial.begin(9600);
  
  //check serial communication - acknowledgement routine
  Serial.println('a'); // sending a charachter to PC
  char a = 'b';
  while (a != 'a')
  {
    //Wait for a specific character from the PC
    a = Serial.read();
  }
  
  //Initiate the Wire library and join the I2C bus as master
  Wire.begin(); 
}

void extendActuator() {
    digitalWrite(relay1, HIGH);
    digitalWrite(relay2, LOW);
}

void retractActuator() {
    digitalWrite(relay1, LOW);
    digitalWrite(relay2, HIGH);
}

void stopActuator() {
    digitalWrite(relay1, LOW);
    digitalWrite(relay2, LOW);
}

void loop() {

   // if there's any serial available, read it:
  if(Serial.available()> 0)//check is any data has been sent by the PC
  {
    //look for the next valid integer in the incoming serial stream: 
    mode = Serial.read();
    
    switch (mode)//used to set different modes from various operations
    {
        case 'A': //UP - RIGHT ARM   
          retractActuator();
          delay(1500);
          stopActuator();
          delay(100); 
        break;
        
        case 'B':  //DOWN - RIGHT ARM
          extendActuator();
          delay(5000);
          stopActuator();
          delay(100);                   
        break;

        case 'P':
          Wire.beginTransmission(5); //transmit to device #5
          Wire.write(mode); //send mode 'P' - Play Start Sound 
          Wire.endTransmission(); // stop transmitting
        break; 

        case 'S':
          Wire.beginTransmission(5); //transmit to device #5
          Wire.write(mode); //send mode 'S' - Stop to Play Start Sound 
          Wire.endTransmission(); // stop transmitting
        break;
    }
  }
}
