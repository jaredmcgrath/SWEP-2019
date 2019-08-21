/////////////////////////////// Set up the libraries ///////////////////////////////////////////////
#include "Wire.h"
#include "math.h"
#include <I2Cdev.h> //Sensing/Communication: Needed to have communication to the sensor module
#include <Adafruit_Sensor.h> //Sensing: Needed to get the sensor data from the accel, gyro, compass and temp unit
#include <Adafruit_LSM9DS0.h> //Sensing: Needed to process the specific sensor's (LSM9DS0) raw data into units
#include <XBee.h>
#include <SoftwareSerial.h>

/////////////////////////////// Program Execution Options ///////////////////////////////////////////////
#define DEBUG 2
#define DEST_ADDRESS 0xBEEF

/////////////////////////////// Bot ID constants - CHANGE FOR EACH ///////////////////////////////////////////////
#define ID 1
int id = ID;

/////////////////////////////// Define all needed pins ///////////////////////////////////////////////
#define MOTOR_R 0 // right motor (A)
#define MOTOR_L 1 // left motor (B)
#define ENCODER_R 2   //Encoder pins
#define ENCODER_L 3   //Encoder pins
#define DIRB 7 // Direction control for motor B
#define DIRA 8 // Direction control for motor A
#define PWMA 9  // PWM control (speed) for motor A
#define PWMB 10 // PWM control (speed) for motor B
#define BATTERY_PIN A1   // battery level indicator pin. Would be hooked up to votlage divider from 9v barrel jack, but currently not implemented

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
#if ID == 0 // Shannon
#define GYRO_CORRECTION_SLOPE 0.000707326F  // slope for the correction line for the gyro readings
#define GYRO_CORRECTION_INTERCEPT 0.840189F    // intercept for the correction line for the gyro readings
#elif ID == 1 // Euler
#define GYRO_CORRECTION_SLOPE -0.006632F  // slope for the correction line for the gyro readings
#define GYRO_CORRECTION_INTERCEPT -3.623982F    // intercept for the correction line for the gyro readings
#elif ID == 2 // Laplace
#define GYRO_CORRECTION_SLOPE -0.015680F  // slope for the correction line for the gyro readings
#define GYRO_CORRECTION_INTERCEPT -3.4F    // intercept for the correction line for the gyro readings
#endif
float gyroTime, gyroStartTime;    // time when gyro measurement taken
float gyroTimePrevious;           // stores the time when the previous gyro measurment was taken !!!NEEDS TO BE INCLUDED IN STARTUP SEQUENCE!!!
float gyroGain;                   // stores the gain value returned by the gyro for the z-axis
float gyroAngleRaw = 0;           // stores the accumulated raw angle, in degrees, measured by the gyroscope from program start
float gyroAngleCorrected;         // stores the corrected angle of the robot, in radians, measured by the gyro

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
float deltaTheta; // change in theta for each iteration of robot motion
float xPosition = 0, yPosition = 0; // Stores the robot's current x and y position estimate from the encoders
float theta = 0; // Stores the current angle of the robot, from the gyro

////////////////////////////// Localization (with XBees) ////////////////////////////////////////
uint8_t rssiValues[32];
uint8_t numBeacons = 0, beacon = 0;
float localX, localY;

////////////////////////////// PID CONTROL ALGORITHM ////////////////////////////////////////////
#define DIVIDER 2                               // Reduces output from controller to level that can be used in motor inputs
float xTarget, yTarget;                 // The current target point the robot is trying to reach
float headingDesired, headingActual;            // Heading angle from current position to target position (the set point, and actual heading of robot
float headingError, headingErrorPrevious = 0;   // Differnece between current heading and desired heading 
float headingErrorCum, headingErrorRate;        // Values cumulative and rate of change for heading error. Used in PID calc
float kP = 150, kI = 0, kD = 0;                  // PID gains, Proportional, Integral and Derivative gain
unsigned long currentTime, previousTime = 900;  // Variables used to help calcualte elapsed time
float elapsedTime;                              // Used to determine the cumulative and rate of change for heading error
float output;                                   // Result from PID controller
int leftInput = 0, rightInput = 0; // A variable to convert the wheel speeds

///////////////////////////// HIT TARGET ///////////////////////////////////////////////////////
#define TARGET_THRESHOLD 0.05F 
float dist = 0;
// Indicates if the bot has a target point to navigate to
bool hasTarget = false;
bool doneLocalizing = true;

////////////////////////////////////////////////////////// Object Declarations //////////////////////////////////////////////////////////
Adafruit_LSM9DS0 lsm = Adafruit_LSM9DS0(); //An object for the sensor module, to be accessed to get the data
SoftwareSerial xbeeSerial(4,5);
XBee xbee = XBee();

// Tx/Rx Objects. Decalred once and reused to conserve space
Tx16Request tx = Tx16Request(DEST_ADDRESS, NULL, 0);
TxStatusResponse txStatus = TxStatusResponse();
XBeeResponse response = XBeeResponse();
Rx16Response rx16 = Rx16Response();

//////////////////////////////// Setup ////////////////////////////////////////////////////////////

void setup(){
  #if DEBUG > 0
  Serial.begin(9600);
  #endif

  // Assuming we have the Xbee on serial port 3
  xbeeSerial.begin(9600);

  // Initialize the XBee with a reference to the broadcast output serial 
  // The default Serial (as opposed to Serial1, etc. on Mega board) stream object, which uses rx pin 0 and tx pin 1
  // This is baked into the Arduino firmware. A virtual Serial could be created using the SoftwareSerial library
  // However, this would require the XBee Arduino header to be rewired to whatever output pins are needed
  xbee.setSerial(xbeeSerial);
  
  botSetup(); // Set's up Bot configuration

  #if DEBUG > 0
  Serial.println(F("\n\nRobot setup complete, beginning main loop\n\n"));
  #endif
}

//////////////////////////////// Main Loop /////////////////////////////////////////////////////////
void loop() {
  botLoop();
}

//////////////////////////////// Functions /////////////////////////////////////////////////////////

void botSetup(){
  #if DEBUG > 0
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
  #if DEBUG > 0
    displaySensorDetails(); //Shows the details about the sensor module
  #endif
  
  configureSensor(); //Configures the sensitivity of the sensor module
  setupArdumoto(); //Sets up the ardumoto shield for the robot's motors

  // Pin config
  pinMode(ENCODER_L, INPUT_PULLUP); // Set the mode for the encoder pins
  pinMode(ENCODER_R, INPUT_PULLUP);
  digitalWrite(ENCODER_L, HIGH); //Initialize the state of the encoder pins
  digitalWrite(ENCODER_R, HIGH);
  attachInterrupt(digitalPinToInterrupt(ENCODER_L), leftEncoderTicks, RISING); //assign the interrupt service routines to the pins
  attachInterrupt(digitalPinToInterrupt(ENCODER_R), rightEncoderTicks, RISING); //This is done on the Uno's interrupts pins so this syntax is valid, else use the PCI syntax 

  // Ask for a target point
  getNextTarget();

  // Start Gyro Angle Calculations
  gyroStartTime = float(millis());
  gyroTimePrevious = float(millis());
  calcGyroAngle();

  #if DEBUG > 0
  Serial.println(F("botSetup completed"));
  #endif
}

//The main loop of the robot, could be moved fully to the loop function if desired, on every iteration, x, y, theta are all
//updated by the encoders and the gyro then the Xbee is checked to see if it has any intruction from MATLAB, then the appropriate
//action is performed
void botLoop() {

  // control process
  // TODO: Figure out optimal delay for positionCalc(), calcGyroAngle(), and controlProcess()
  // Currently, all happen once every 100ms
  if (hasTarget && (millis() - previousTime) > 100){
      // Update bot position using encoders/dead reckoning
    positionCalc();
    // Calculates heading using the gyroscope
    calcGyroAngle();
    controlProcess();
    
    #if DEBUG > 1
    printResults();
    #endif

    hitTarget();
  }
  
  // Check for any instructions
  checkForIns();
}
