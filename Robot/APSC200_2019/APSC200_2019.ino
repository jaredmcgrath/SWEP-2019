/////////////////////////////// Set up the libraries ///////////////////////////////////////////////
#include "Wire.h"
#include "math.h"
#include <I2Cdev.h> //Sensing/Communication: Needed to have communication to the sensor module
#include <Adafruit_Sensor.h> //Sensing: Needed to get the sensor data from the accel, gyro, compass and temp unit
#include <Adafruit_LSM9DS0.h> //Sensing: Needed to process the specific sensor's (LSM9DS0) raw data into units
#include <XBee.h>
#include <SoftwareSerial.h>

/////////////////////////////// Program Execution Options ///////////////////////////////////////////////
// DEBUG prints more stuff for debugging
#define DEBUG 0
// MEGA is 1 if the board is an arduino mega. In this case, the XBee will communicate over Serial3. Otherwise, the XBee will use a software serial
#define MEGA 0
// DEST_ADDRESS is the MY address of the main XBee, which all robots will send responses to
#define DEST_ADDRESS 0xBEEF

/////////////////////////////// Define all needed pins ///////////////////////////////////////////////
#define MOTOR_R 0 // right motor (A)
#define MOTOR_L 1 // left motor (B)
#define ENCODER_R 2   //Encoder pins
#define ENCODER_L 3   //Encoder pins
#define DIRB 7 // Direction control for motor B
#define DIRA 8 // Direction control for motor A
#define PWMA 9  // PWM control (speed) for motor A
#define PWMB 10 // PWM control (speed) for motor B
#define BATTERY_PIN A1   // battery level indicator pin. Not implemented

/*
 * Data structures used for encoding/decoding information
 */
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

/////////////////////////////// Gyro Constants & Variables /////////////////////////////////////////////////
#define GYRO_CORRECTION_SLOPE 0.000808367F  // slope for the correction line for the gyro readings
#define GYRO_CORRECTION_INTERCEPT -0.921095F    // intercept for the correction line for the gyro readings
float gyroTime;                             // time when gyro measurement taken
float gyroTimePrevious = 800;     // stores the time when the previous gyro measurment was taken !!!NEEDS TO BE INCLUDED IN STARTUP SEQUENCE!!!
float gyroGain;                   // stores the gain value returned by the gyro for the z-axis
float gyroAngleRaw = 0;           // stores the accumulated raw angle, in degrees, measured by the gyroscope from program start

/////////////////////////////// Sensor Variables ///////////////////////////////////////////////
sensor_t accelSetup, magSetup, gyroSetup, tempSetup; //Variables used to setup the sensor module
sensors_event_t accel, mag, gyro, temp; // Variables to store current sensor event data

/////////////////////////////// Encoder Variables ///////////////////////////////////////////////
int oldLeftEncoder = 0, oldRightEncoder = 0; // Stores the encoder value from the loop prior to estimate x, y position
int leftEncoder = 0, rightEncoder = 0; // Stores the encoder values for the current loop
int lastLeftTicks = 0, lastRightTicks = 0; // Ticks upon last call of getLeftTicks/getRightTicks

/////////////////////////////// Position Variables ///////////////////////////////////////////////
float rWheel = 0.034, rChasis = 0.08;// Radius of the robot wheels
float leftRads = 0, rightRads = 0; // Stores the left and right radians of the wheels (from encoder values)
float xPosition = 0, yPosition = 0; // Stores the robot's current x and y position estimate from the encoders
float theta = 0; // Stores the current angle of the robot, from the gyro

////////////////////////////// Localization (with XBees) ////////////////////////////////////////
uint8_t rssiValues[32];
uint8_t numBeacons = 0, beacon = 0;

/////////////////////////////// Other Variables /////////////////////////////////////////////////
int leftInput = 0, rightInput = 0; // A variable to convert the wheel speeds from char (accepted), to int

// Interruptible movement variables
// If Arduino is moving for a fixed duration
bool isMovingFixed = false;
// Clock value to stop movement at
unsigned long endTime;

/////////////////////////////// Agent Tag Data - CHANGE FOR EACH ROBOT ///////////////////////////////////////////////
/*
 * Shannon = 0
 * Euler = 1
 * Laplace = 2
 */
byte id = 0;

////////////////////////////////////////////////////////// Object Declarations //////////////////////////////////////////////////////////
// Sensor module object declaration
Adafruit_LSM9DS0 lsm = Adafruit_LSM9DS0();
// XBee object declaration
XBee xbee = XBee();

#if MEGA
Stream xbeeSerial = Serial3;
#else
SoftwareSerial xbeeSerial(4,5);
#endif

// Tx/Rx Objects. Decalred once and reused to conserve space
Tx16Request tx = Tx16Request(DEST_ADDRESS, NULL, 0);
TxStatusResponse txStatus = TxStatusResponse();
XBeeResponse response = XBeeResponse();
Rx16Response rx16 = Rx16Response();

//////////////////////////////// Setup ////////////////////////////////////////////////////////////

void setup(){
  #if DEBUG
  Serial.begin(9600);
  #endif

  // Initialize the XBee Serial
  xbeeSerial.begin(9600);

/*
 * The XBee needs a reference to a Stream object to act as a serial port for communication.
 * The Stream object needs to be physically wired to the XBee shield's rx and tx pins.
 * 
 * All Arduino boards have a hardware serial named Serial, connected to pins 0 and 1.
 * This serial port is used to program the Arduino's EEPROM when code is uploaded, and when calling 
 * Serial.print() for debugging purposes. This means on Arduino Uno boards, a SoftwareSerial must be used
 * to use the XBee hile the Serial is used for debug prints.
 * 
 * In addition to Serial, an Arduino Mega board has multiple hardware serials, namely Serial1, Serial2, and Serial3.
 * These ports are connected to pins 14-21. When using a Mega, we use the Serial3 for the XBee's serial port
 * because hardware serial ports perform better.
 */
  xbee.setSerial(xbeeSerial);
  
  botSetup(); // Sets up Bot configuration

  #if DEBUG
  Serial.println(F("\n\nRobot setup complete, beginning main loop\n\n"));
  #endif
}

//////////////////////////////// Main Loop /////////////////////////////////////////////////////////
void loop() {
  botLoop();
}

//////////////////////////////// Functions /////////////////////////////////////////////////////////

void botSetup(){
  #if DEBUG
  Serial.println(F("botSetup started"));
  #endif
  
  #ifndef ESP8266         // from sensor module example code, don't know if we need this 
    while (!Serial);     // will pause Zero, Leonardo, etc until serial console opens
  #endif

  // Ensure sensor module is intact
  if(!lsm.begin()) {
    Serial.print(F("Ooops, no LSM9DS0 detected ... Check your wiring!"));
    while(1);
  }

  // Setup routines
  #if DEBUG
  displaySensorDetails();
  #endif

  // Configure sensor module sensitivity
  configureSensor();
  // Set up the ardumoto shield for the robot's motors
  setupArdumoto();

  // Pin config
  pinMode(ENCODER_L, INPUT_PULLUP); // Set the mode for the encoder pins
  pinMode(ENCODER_R, INPUT_PULLUP);
  digitalWrite(ENCODER_L, HIGH); //Initialize the state of the encoder pins
  digitalWrite(ENCODER_R, HIGH);
  attachInterrupt(digitalPinToInterrupt(ENCODER_L), leftEncoderTicks, RISING); //assign the interrupt service routines to the pins
  attachInterrupt(digitalPinToInterrupt(ENCODER_R), rightEncoderTicks, RISING); //This is done on the Uno's interrupts pins so this syntax is valid, else use the PCI syntax 
  
  #if DEBUG
  Serial.println(F("botSetup completed"));
  #endif
}

//The main loop of the robot, could be moved fully to the loop function if desired, on every iteration, x, y, theta are all
//updated by the encoders and the gyro then the Xbee is checked to see if it has any intruction from MATLAB, then the appropriate
//action is performed
void botLoop(){
  // Update bot position using encoders/dead reckoning
  positionCalc();
  // Check for any instructions
  checkForIns();
  // Check if movement should be interrupted
  interruptMovement();
}
