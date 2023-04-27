
#include <Arduino.h>
#include <WiFiNINA.h>
#include <Arduino_ConnectionHandler.h>
#include <ArduinoHttpClient.h

void setup() {

}

void loop() {

}

// rounds a number to 2 decimal places
// example: round(3.14159) -> 3.14
double round2(double value) {
   return (int)(value * 100 + 0.5) / 100.0;
}