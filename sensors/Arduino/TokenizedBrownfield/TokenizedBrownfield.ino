#include <SPI.h>
#include "Adafruit_GFX.h"
#include "Adafruit_ILI9341.h"
//#include <RunningMedian.h>
//#include <math.h>

//int powerLevels = 0;
//int prevPowerLevels = 0;
//const int ANALOG_REFERENCE = 3300; // 3300 millivots
//const int CURRENT = 1; // 1 milliamp
//const int SECONDS_IN_HOUR = 3600;
//unsigned long previousMillis = 0;  // will store last time power was updated
//const long INTERVAL = 60000;  // interval at which to check power levels
//RunningMedian runningMedian = RunningMedian(5);

// keep track of the number of tokens minted (and the time)
int ERC20Count = 0;
int ERC721Count = 0;
bool erc20Minted = false;
bool erc721Minted = false;
String timestamp = "";

// pollution levels
String benzoApyrene = "";
String arsenic = "";
String pH = "";

/*******************
SERIAL COMMUNICATION
*******************/
// == serial == //
String serialStr = "";
boolean serialStrReady = false;

//========= IlI9341 display ===========//
#define TFT_RST 8
#define TFT_DC 9
#define TFT_CS 10
// Use hardware SPI (on Uno & Nano (including 33iot), #13, #12, #11) and the above for CS, DC & Reset
Adafruit_ILI9341 tft = Adafruit_ILI9341(TFT_CS, TFT_DC, TFT_RST);

void setup() {
   // initialize serial communication at 9600 bits per second:
   Serial.begin(9600);
   while(!Serial) {
      ; // wait for the serial port to connect
   }

   //establishContact();

   // initialize the ILI9341 display
   tft.begin();

   // read diagnostics (optional but can help debug problems)
   uint8_t x = tft.readcommand8(ILI9341_RDMODE);
   Serial.print(F("Display Power Mode: 0x")); Serial.println(x, HEX);
   x = tft.readcommand8(ILI9341_RDMADCTL);
   Serial.print(F("MADCTL Mode: 0x")); Serial.println(x, HEX);
   x = tft.readcommand8(ILI9341_RDPIXFMT);
   Serial.print(F("Pixel Format: 0x")); Serial.println(x, HEX);
   x = tft.readcommand8(ILI9341_RDIMGFMT);
   Serial.print(F("Image Format: 0x")); Serial.println(x, HEX);
   x = tft.readcommand8(ILI9341_RDSELFDIAG);
   Serial.print(F("Self Diagnostic: 0x")); Serial.println(x, HEX);

   tft.setRotation(2); // flip
}

void loop() {
/*    unsigned long currentMillis = millis();
   if (currentMillis - previousMillis >= INTERVAL) {
      // save the last time you checked the power levels
      previousMillis = currentMillis;
      runningMedian.add(analogRead(A0));
      long m = runningMedian.getMedian();
      float voltage = m * (ANALOG_REFERENCE / 1023.0);
      float power = CURRENT * voltage; // in milliwatts
      power = power / 60.0; // milliwatt hours
      powerLevels = round(power) + prevPowerLevels; // add the current power levels to the previous
      prevPowerLevels = powerLevels;
   } */

   //check serial port for new commands
   readSerial();
   if(serialStrReady) {
      processSerial();
   }

   if(erc20Minted) {
      // now reset the minted flag to false
      Serial.println(F("ERC-20 minted."));
      erc20Minted = false;
   }

   if(erc721Minted) {
      // ---- DRAW SOMETHING HERE!!! ---- //


      // now reset the minted flag to false
      updateDisplay();
      Serial.println(F("ERC-721 minted. Updating mini-display."));
      erc721Minted = false;
   }
   
   delay(1);
}

void readSerial() {
   // pulls in characters from serial port as they arrive
   // builds serialStr and sets ready flag when newline is found
   // serial data will only be sent to Arduino when minting occurs, so consider this a minting "flag"
   while (Serial.available()) {
    char inChar = (char)Serial.read(); 
    if (inChar == '\n') {
      serialStrReady = true;
    } else {
      serialStr += inChar;
    }
  }
}

void processSerial() {
   // process the serial data from node.js app
   serialStr.trim(); //remove any \r \n whitespace at the end of the String
   int firstCommaIdx = serialStr.indexOf(',');
   int secondCommaIdx = serialStr.indexOf(',', firstCommaIdx+1);
   int thirdCommaIdx = serialStr.indexOf(',', secondCommaIdx+1);
   int fourthCommaIdx = serialStr.indexOf(',', thirdCommaIdx+1);
   int fifthCommaIdx = serialStr.indexOf(',', fourthCommaIdx+1);
   benzoApyrene = serialStr.substring(0, firstCommaIdx);
   arsenic = serialStr.substring(firstCommaIdx+1, secondCommaIdx);
   float phF = serialStr.substring(secondCommaIdx+1, thirdCommaIdx).toInt() / 100.0; // convert pH value to float (with proper decimal place)
   pH = String(phF);
   int numERC20TokensMinted = serialStr.substring(thirdCommaIdx+1, fourthCommaIdx).toInt();
   int numERC721TokensMinted = serialStr.substring(fourthCommaIdx+1, fifthCommaIdx).toInt();
   timestamp = serialStr.substring(fifthCommaIdx+1);

   // check if tokens were actually minted
   if(numERC20TokensMinted > ERC20Count) {
      erc20Minted = true;
      ERC20Count = numERC20TokensMinted;
   }

   if(numERC721TokensMinted > ERC721Count) {
      erc721Minted = true;
      // update the count
      ERC721Count = numERC721TokensMinted;
   }

   // send the the powerLevels back to the node.js app
   //Serial.print(powerLevels);
   //Serial.print("\n");
   serialStrReady = false;
   serialStr = "";
}

// rounds a number to 2 decimal places
// example: round(3.14159) -> 3.14
double round2(double value) {
   return (int)(value * 100 + 0.5) / 100.0;
}

void updateDisplay() {
   tft.fillScreen(0x6B6D);
   tft.setCursor(0, 0);
   tft.setTextColor(0xF7BE);
   tft.setTextSize(2);
   tft.print(F("Brownfield Certificate "));
   char buf[4]; // 4 characters + NUL for leading zeros
   sprintf(buf, "%03d", ERC721Count);
   tft.setTextSize(1);
   tft.println(buf);
   tft.println();
   tft.println("Time: " + timestamp);
   tft.println("Benzo(a)pyrene: " + benzoApyrene + " PPM (top)");
   tft.println("Arsenic: " + arsenic + " PPM (middle)");
   tft.println("pH: " + pH + " (bottom)");
}

/* void establishContact() {
   while (Serial.available() <= 0) {
    Serial.print("0");  // send an initial string
    delay(300);
  }
} */