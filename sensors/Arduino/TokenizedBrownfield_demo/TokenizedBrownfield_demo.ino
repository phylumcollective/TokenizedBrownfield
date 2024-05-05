#include <SPI.h>
#include "Adafruit_GFX.h"
#include "Adafruit_ILI9341.h"


const int INTERVAL = 60;  // interval at which to update display (3600 seconds = 1 hour)
const long INTERVAL_MILLIS = 60000;
int remainingTime = INTERVAL;
int prevRemainingTime = INTERVAL;
unsigned long prevMillis = 0;
int startTime;


// keep track of the number of tokens minted (and the time)
int ERC20Count = 0;
int ERC721Count = 0;

// pollution levels
float benzoApyrene = 1.5;
float arsenic = 10.0;
float pH = 6.9;

long randNum;


//========= IlI9341 display ===========//
#define TFT_RST 8
#define TFT_DC 9
#define TFT_CS 10
// Use hardware SPI (on Uno & Nano (including 33iot), #13, #12, #11) and the above for CS, DC & Reset
Adafruit_ILI9341 tft = Adafruit_ILI9341(TFT_CS, TFT_DC, TFT_RST);

// TEXT COLORS:
// Color definitions
#define BLACK    0x0000
#define BLUE     0x001F
#define RED      0xF800
#define GREEN    0x07E0
#define CYAN     0x07FF
#define MAGENTA  0xF81F
#define YELLOW   0xFFE0 
#define WHITE    0xFFFF

void setup() {
  // initialize serial communication at 9600 bits per second:
  Serial.begin(9600);
  while(!Serial) {
    ; // wait for the serial port to connect
  }

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

  updateDisplay();

  startTime = millis();
}

void loop() {
  unsigned long currMillis = millis();
  // Calculate the elapsed time in seconds
  int elapsedTime = round((currMillis - startTime) / 1000.0);
  // Calculate remaining time
  remainingTime = INTERVAL - elapsedTime;
  //Serial.println(remainingTime);

  if(remainingTime < prevRemainingTime) {
    prevRemainingTime = remainingTime;
    updateTime();
  }

  if(currMillis - prevMillis >= INTERVAL_MILLIS) {
    prevMillis = currMillis;
    prevRemainingTime = INTERVAL;
    ERC20Count++;
    Serial.println(F("ERC-20 minted."));
    randNum = random(10); // random number from 0 to 9
    if (randNum >= 9) {
      benzoApyrene = benzoApyrene - (random(3) / 100.0);
      arsenic = arsenic - (random(3) / 100.0);
      pH = pH - (random(-2, 2) / 100.0);
      ERC721Count++;
      Serial.println(F("ERC-721 minted."));
    }
    updateDisplay();
    startTime = millis(); // reset the timer
  }
  //delay(1);
}


void updateDisplay() {
  tft.fillScreen(0x6B6D);
  tft.setCursor(0, 0);
  tft.setTextColor(YELLOW);
  tft.setTextSize(2);
  tft.println(F("Brownfield "));
  tft.print(F("Certificate "));
  char buf[4]; // 3 characters + NUL for leading zeros
  sprintf(buf, "%03d", ERC721Count);
  tft.setTextSize(1);
  tft.println(buf);
  tft.println();
  tft.println();
  tft.println();
  tft.setTextColor(RED);
  char buf1[3]; // 2 characters + NUL for leading zeros
  sprintf(buf1, "%02d", remainingTime);
  tft.setTextSize(2);
  tft.print(":");
  tft.println(buf1);
  tft.println();
  tft.setTextSize(1);
  tft.setTextColor(0xF7BE);
  tft.print("Benzo(a)pyrene: ");
  tft.print(benzoApyrene);
  tft.println(" PPM");
  tft.print("Arsenic: ");
  tft.print(arsenic);
  tft.println(" PPM");
  tft.print("pH: ");
  tft.print(pH);
  tft.println(" PPM");
  tft.println();
  tft.println();
  tft.println();
  tft.println("Soil Source:");
  tft.println("43.13788, -77.62065");
  tft.println("(Vacuum Oil Refinery)");
  tft.println("Rochester, NY");
  tft.println();
  tft.println();
  tft.println();
  tft.print("ERC-20 tokens minted: ");
  tft.println(ERC20Count);
  tft.println();
  tft.println();
  tft.println();
  tft.println("Brownfield Toeknization Prototype");
  tft.println("Part of the TerraRete platform");
  tft.println("https://is.gd/TerraRete");

}

void updateTime() {
  tft.setCursor(0, 48);
  tft.setTextColor(RED, 0x6B6D);
  tft.setTextSize(2);
  char buf1[3]; // 2 characters + NUL for leading zeros
  sprintf(buf1, "%02d", remainingTime);
  tft.print(":");
  tft.println(buf1);
}

