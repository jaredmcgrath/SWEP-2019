/////////////////////////////// Set up the libraries ///////////////////////////////////
// IMPORTANT: "#define NO_PORTD_PINCHANGES" must be before "#include <SoftSerialFix.h>"
#define NO_PORTD_PINCHANGES // to indicate that port d will not be used for pin change interrupts
// #include <PinChangeInt.h> //Needed with the above line to have more interrupts that dont interfere with the Xbee
// #include <SoftSerialFix.h> //Communication: Needed to create a software serial port for the Xbee
#include "Wire.h"
#include "math.h"
// #include <I2Cdev.h> //Sensing/Communication: Needed to have communication to the sensor module
// #include <Adafruit_Sensor.h> //Sensing: Needed to get the sensor data from the accel, gyro, compass and temp unit
// #include <Adafruit_LSM9DS0.h> //Sensing: Needed to process the specific sensor's (LSM9DS0) raw data into units
#include <IRremote.h>   // Localization: Needed to read received IR patterns

/////////////////////////////// Program Execution Options //////////////////////////////
#define DEBUG 1

/////////////////////////////// Program Parameters /////////////////////////////////////
// Beacon Parameters
#define DATA_PADDING_VALUE 2147483648 // (0x80000000) added before transmission to ensure that the transmission is 32 bits
#define NUM_BEACONS 1 // Number of beacons being tested. Total numebr of beacons is currently 3 (5 in future)

/////////////////////////////// Define all needed pins /////////////////////////////////
#define US_OUTPUT 4 // Ouput to US sensors
#define IR_OUTPUT 3 // Input to IR sensors
IRsend irsend;

/////////////////////////////// Program Variables //////////////////////////////////////
int counter = 0;

void setup() 
{
  Serial.begin(9600);
  Serial.println(F("Beacon Setup Begin"));
  pinMode(US_OUTPUT, OUTPUT);
  Serial.println(F("Beacon Setop Completed"));
}

void loop() 
{
  // Countdown to signal transmission
  Serial.print(F("Signal transmission in: 3,"));
  delay(1000);
  Serial.print(F(" 2,"));
  delay(1000);
  Serial.println(F(" 1"));
  delay(1000);

  // Transmission of IR and US signal
  irsend.sendRC5(4294967294,32);
  delay(10);
  analogWrite(US_OUTPUT, 255); // Sending a US signal to the bot.
  counter++;

  // Confirming that the transmission code was executed
  Serial.print(F("Transmission "));
  Serial.print(counter);
  Serial.println(F(" Sent"));
  delay(3000);
}
