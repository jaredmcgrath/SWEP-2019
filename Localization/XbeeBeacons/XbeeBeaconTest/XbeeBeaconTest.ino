/*
 The purpose of this program is test the feasability of using Radio Signal Strength
 to determine the distance between two points of communication. 
 To achieve this, this program was written to send a character 'H' over the XBee 
 to another XBee on a repeating basis. The receiving XBee will then determine the 
 RSS of the received transmission.  
*/

// Software serial library
#include "SoftwareSerial.h"

#define LED 13 // Built in LED on Arduino
#define XBEE_RX 2 // RX: Arduino pin 2, XBee pin DOUT
#define XBEE_TX 3 // TX: Arduino pin 3, XBee pin DIN
SoftwareSerial XBee(2,3);

void setup() 
{
  Serial.begin(9600); // Establishing serial connection with host PC
  XBee.begin(9600); // Establishing serial connection with XBee

  pinMode(LED, OUTPUT); // Establishing Pin 13 as LED Pin
}

void loop() 
{
  // Blink LED 3 times to signal that a transmission is about to be sent
  for (int i = 1; i < 3; i++)
  {
    digitalWrite(LED, HIGH);
    delay(500);
    digitalWrite(LED, LOW);
    delay(500);
  } 

  // Send transmision
  XBee.write('H');

  // Wait 7.5 seconds to allow for processing on the other end. 
  delay(7500);
}
