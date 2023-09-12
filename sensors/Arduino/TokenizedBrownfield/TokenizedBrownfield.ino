#include <SPI.h>
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

/*******************
SERIAL COMMUNICATION
*******************/
// == serial == //
String serialStr = "";
boolean serialStrReady = false;

void setup() {
   // initialize serial communication at 9600 bits per second:
   Serial.begin(9600);
   while(!Serial) {
      ; // wait for the serial port to connect
   }
   establishContact();
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
   int benzoApyrene = serialStr.substring(0, firstCommaIdx).toInt();
   int arsenic = serialStr.substring(firstCommaIdx+1, secondCommaIdx).toInt();
   int pH = serialStr.substring(secondCommaIdx+1, thirdCommaIdx).toInt();
   int numERC20TokensMinted = serialStr.substring(thirdCommaIdx+1, fourthCommaIdx).toInt();
   int numERC721TokensMinted = serialStr.substring(fourthCommaIdx+1).toInt();

   // convert pH value to float (with proper decimal place)
   float pH_f = pH/100.0;

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

void establishContact() {
   while (Serial.available() <= 0) {
    Serial.print("0");  // send an initial string
    delay(300);
  }
}