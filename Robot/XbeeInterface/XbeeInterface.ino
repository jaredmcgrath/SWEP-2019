#include <XBee.h>

#define DEST_ADDRESS 0xBEEF
#define BATTERY_PIN 1
#define MOTOR_L 2
#define MOTOR_R 3
#define DEBUG 1

typedef union {
  float f;
  unsigned long uLong;
  long l;
  uint8_t b[4];
} ByteArray4;

typedef union {
  int16_t int16;
  uint8_t b[2];
} ByteArray2;

typedef struct {
  float x;
  float y;
  float a;
  unsigned long t;
} PosStruct;

typedef union {
  PosStruct posStruct;
  uint8_t b[16];
} ByteArray16;

// Variables for testing
float xPosition = 0, yPosition = 0, theta = 0;
int leftInput = 0, rightInput = 0;
unsigned long endTime;
bool isMovingFixed = false, isThetaSet = false;
int lastLeftTicks = 0, lastRightTicks = 0, leftEncoder = 0, rightEncoder = 0;

uint8_t rssiValues[32];
uint8_t numBeacons = 0, beacon = 0;

XBee xbee = XBee();

Tx16Request tx = Tx16Request(DEST_ADDRESS, NULL, 0);

TxStatusResponse txStatus = TxStatusResponse();

// Generic response, before cast to specific response type
XBeeResponse response = XBeeResponse();
Rx16Response rx16 = Rx16Response();
Rx64Response rx64 = Rx64Response();

void driveArdumoto(uint8_t pin, int val) {
  return;
}

void setup() {
  Serial.begin(9600);
  Serial3.begin(9600);

  #if DEBUG
  Serial.println(F("Setup started"));
  #endif
  
  // Initialize the XBee with a reference to the broadcast output serial 
  // The default Serial (as opposed to Serial1, etc. on Mega board) stream object, which uses rx pin 0 and tx pin 1
  // This is baked into the Arduino firmware. A virtual Serial could be created using the SoftwareSerial library
  // However, this would require the XBee Arduino header to be rewired to whatever output pins are needed
  xbee.setSerial(Serial3);

  #if DEBUG
  Serial.println(F("Setup Complete"));
  #endif
}

void loop() {
  checkForIns();
}
