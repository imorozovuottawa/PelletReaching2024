/*************************************************** 
  Slave MP3Shield
 ****************************************************/

// include SPI, MP3 and SD libraries
#include <SPI.h>
#include <Adafruit_VS1053.h>
#include <SD.h>
#include <Wire.h>
const byte SlaveID = 5;

// These are the pins used for the breakout example
#define BREAKOUT_RESET  9      // VS1053 reset pin (output)
#define BREAKOUT_CS     10     // VS1053 chip select pin (output)
#define BREAKOUT_DCS    8      // VS1053 Data/command select pin (output)
// These are the pins used for the music maker shield
#define SHIELD_RESET  -1      // VS1053 reset pin (unused!)
#define SHIELD_CS     7      // VS1053 chip select pin (output)
#define SHIELD_DCS    6      // VS1053 Data/command select pin (output)

// These are common pins between breakout and shield
#define CARDCS 4     // Card chip select pin
// DREQ should be an Int pin, see http://arduino.cc/en/Reference/attachInterrupt
#define DREQ 3       // VS1053 Data request, ideally an Interrupt pin

Adafruit_VS1053_FilePlayer musicPlayer = Adafruit_VS1053_FilePlayer(SHIELD_RESET, SHIELD_CS, SHIELD_DCS, DREQ, CARDCS);

//***********************************************************************************
//initialize variables
const int arraySize = 4;
char songs[arraySize][10] = {{"3.WAV"},{"9.WAV"},{"50.WAV"},{"250.WAV"}};
int songNumber = 0;
char songMode = 'P';
    
void setup() {
  Wire.begin(SlaveID); // join i2c bus with address #5
  musicPlayer.begin();
  SD.begin(CARDCS); //initilise the SD card
   // Set volume for left, right channels. lower numbers == louder volume!
  musicPlayer.setVolume(50,50);
  musicPlayer.useInterrupt(VS1053_FILEPLAYER_PIN_INT); // DREQ int  
  Wire.onReceive(receiveEvent); // register event to be called when slave receive a transmition from master
}
//*************************************************************************************
void loop() { 
  // Nothing to do
 // delay(100);
}
//**************************************************************************************
// function that executes whenever data is received from master
// this function is register as an event, see setup()
void receiveEvent( int howMany) {
  if (Wire.available()) {
    songMode = Wire.read(); // receive byte as a character
    switch (songMode){
      case 'P':
        songNumber = 0;
      break;
    }
    if (songMode == 'S'){
      musicPlayer.stopPlaying();
    }
    else {
      musicPlayer.startPlayingFile(songs[songNumber]);

    }
  } 
}
//***************************************************************************************

