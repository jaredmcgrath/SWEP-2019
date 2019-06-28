#include <XBee.h>
#include <SoftwareSerial.h>

#define DEBUG 0

SoftwareSerial xbeeSerial(4,5);
XBeeWithCallbacks xbee;

void setup() {
  #if DEBUG
  Serial.begin(9600);
  #endif

  // Initialize the XBee software serial
  xbeeSerial.begin(9600);

  // Initialize serial communication over the XBee interface
  xbee.begin(&xbeeSerial);
  // Set XBee callback functions
  

  #if DEBUG
  Serial.println(F("Setup Complete"));
  #endif
}

void loop() {
  xbee.loop();
}
