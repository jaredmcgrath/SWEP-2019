#include <XBee.h>

XBee xbee = XBee();

uint8_t payload[32];

Tx16Request tx = Tx16Request(0x0001, payload, sizeof(payload));

TxStatusResponse txStatus = TxStatusResponse();

// Generic response, before cast to specific response type
XBeeResponse response = XBeeResponse();
Rx16Response rx16 = Rx16Response();
Rx64Response rx64 = Rx64Response();

void setup() {
  Serial.begin(9600);
  Serial3.begin(9600);
  Serial.println(F("Setup started"));
  
  // Initialize the XBee with a reference to the broadcast output serial 
  // The default Serial (as opposed to Serial1, etc. on Mega board) stream object, which uses rx pin 0 and tx pin 1
  // This is baked into the Arduino firmware. A virtual Serial could be created using the SoftwareSerial library
  // However, this would require the XBee Arduino header to be rewired to whatever output pins are needed
  xbee.setSerial(Serial3);

  Serial.println(F("Setup Complete"));
}

void loop() {
  checkForIns();
}
