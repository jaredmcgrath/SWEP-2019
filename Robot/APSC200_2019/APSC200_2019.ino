/////////////////////////////// Set up the libraries ///////////////////////////////////////////////
#include "Wire.h"
#include "math.h"
#include <I2Cdev.h> //Sensing/Communication: Needed to have communication to the sensor module
#include <Adafruit_Sensor.h> //Sensing: Needed to get the sensor data from the accel, gyro, compass and temp unit
#include <Adafruit_LSM9DS0.h> //Sensing: Needed to process the specific sensor's (LSM9DS0) raw data into units
#include <XBee.h>
#include <SoftwareSerial.h>

/////////////////////////////// Program Execution Options ///////////////////////////////////////////////
#define DEBUG 0
#define PRINT_RESULTS 1
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
#define GYRO_CORRECTION_SLOPE 0.000808367F  // slope for the correction line for the gyro readings
#define GYRO_CORRECTION_INTERCEPT -0.921095F    // intercept for the correction line for the gyro readings
float gyroTime;                             // time when gyro measurement taken
float gyroTimePrevious = 800;     // stores the time when the previous gyro measurment was taken !!!NEEDS TO BE INCLUDED IN STARTUP SEQUENCE!!!
float gyroGain;                   // stores the gain value returned by the gyro for the z-axis
float gyroAngleRaw = 0;           // stores the accumulated raw angle, in degrees, measured by the gyroscope from program start
float gyroAngleCorrected;         // stores the corrected angle of the robot, in radians, measured by the gyro

/////////////////////////////// Sensor Variables ///////////////////////////////////////////////
sensor_t accelSetup, magSetup, gyroSetup, tempSetup; //Variables used to setup the sensor module
sensors_event_t accel, mag, gyro, temp; // Variables to store current sensor event data
//float heading, baseline = 0; // Variables to store the calculated heading and the baseline variable (Baseline may be unnecessary)
bool isThetaSet = false;

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
uint8_t *rssiValues;
uint8_t numBeacons = 0, beacon = 0;

////////////////////////////// PID CONTROL ALGORITHM ////////////////////////////////////////////
#define DIVIDER 2                               // Reduces output from controller to level that can be used in motor inputs
float xTarget[] = {2,2,0,0}, yTarget[] = {0,2,2,0};                 // The current target point the robot is trying to reach
int counter = 0;
float headingDesired, headingActual;            // Heading angle from current position to target position (the set point, and actual heading of robot
float headingError, headingErrorPrevious = 0;   // Differnece between current heading and desired heading 
float headingErrorCum, headingErrorRate;        // Values cumulative and rate of change for heading error. Used in PID calc
float kP = 150, kI = 0, kD = 0;                  // PID gains, Proportional, Integral and Derivative gain
unsigned long currentTime, previousTime = 900;  // Variables used to help calcualte elapsed time
float elapsedTime;                              // Used to determine the cumulative and rate of change for heading error
float output;                                   // Result from PID controller
int leftMotorInput, rightMotorInput;            // Right and left motor inputs

///////////////////////////// HIT TARGET ///////////////////////////////////////////////////////
#define TARGET_THRESHOLD 0.05F 
float dist = 0;


/////////////////////////////// Other Variables /////////////////////////////////////////////////
int leftInput = 0, rightInput = 0; // A variable to convert the wheel speeds from char (accepted), to int

// Interruptible movement variables
// If Arduino is moving for a fixed duration
bool isMovingFixed = false;
// Clock value to stop movement at
unsigned long endTime;

/////////////////////////////// Agent Tag Data - CHANGE FOR EACH ROBOT ///////////////////////////////////////////////
/*
 * ID's should be numbered 0-6 inclusively
 */
byte message[2];
#define ALL_AGENTS 7
#define ID 0
byte id = ID;

////////////////////////////////////////////////////////// Object Declarations //////////////////////////////////////////////////////////
Adafruit_LSM9DS0 lsm = Adafruit_LSM9DS0(); //An object for the sensor module, to be accessed to get the data
SoftwareSerial xbeeSerial(4,5);
XBee xbee = XBee();
// Tx/Rx Objects. Decalred once and reused to conserve space
Tx16Request tx = Tx16Request(DEST_ADDRESS, NULL, 0);
TxStatusResponse txStatus = TxStatusResponse();
// Generic response, before cast to specific response type
XBeeResponse response = XBeeResponse();
Rx16Response rx16 = Rx16Response();

//////////////////////////////// Setup ////////////////////////////////////////////////////////////

void setup(){
  #if DEBUG || PRINT_RESULTS
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

  // Initialize serial port via XBee
  
  // Ensure sensor module is intact
  if(!lsm.begin()) {
    Serial.print(F("Ooops, no LSM9DS0 detected ... Check your wiring!"));
    while(1);
  }

  // Setup routines
  displaySensorDetails(); //Shows the details about the sensor module, could be removed or put in an if(DEBUG) statement
  configureSensor(); //Configures the sensitivity of the sensor module
  setupArdumoto(); //Sets up the ardumoto shield for the robot's motors

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
  // Calculates heading using the gyroscope
  calcGyroAngle();
  // control process, if statement used as a delay between running control and hit target functions
  if(millis() - currentTime > 100){
    controlProcess();
    
    #if PRINT_RESULTS
    printResults();
    #endif

    hitTarget();
  }
  // Print results from positionCalc, calcGyroAngle and controlProcess for each iteration of the main runtime loop
  #if PRINT_RESULTS
  printResults();
  #endif
  
  // Check for any instructions
  checkForIns();
  // Check if movement should be interrupted
  interruptMovement();
}

// This function controls the motion of the robot such that it reaches its destination target
void controlProcess(){
  // Obtain current time and calculate the time elapsed from the previous run of the function
  currentTime = millis();
  elapsedTime = (float) currentTime - previousTime;

  // Calculate how 'off' the robot's heading is
  headingDesired = atan2((yTarget[counter]-yPosition),(xTarget[counter]-xPosition));

  // Adjust headingActual to be within bounds of -PI to PI.
  headingActual = gyroAngleCorrected;
  if (headingActual > PI){
    headingActual -= 2*PI;
  }
  
  // determining error on heading
  headingError = headingDesired - headingActual;

  // Ensures headingError is within bounds of -PI to PI
  if (headingError < -PI){
    headingError += 2*PI;
  }
  else if (headingError > PI){
    headingError -= 2*PI;
  }

  // Cumulative error on heading and rate of change of heading error
  headingErrorCum += headingError * elapsedTime/1000;
  headingErrorRate = (headingError - headingErrorPrevious)/(elapsedTime/1000);

  // Control equation
  output = kP*headingError + kI*headingErrorCum + kD*headingErrorRate;

  // Saving data that will be required for the next iteration of control algorithm
  headingErrorPrevious = headingError;
  previousTime = currentTime;

  // Calculates the wheel inputs using the control output
  leftMotorInput = 120 - output/DIVIDER;
  rightMotorInput = 120 + output/DIVIDER;

  // Ensures wheels still rotate and dont slip.
  if (leftMotorInput < 80){
    leftMotorInput = 80;
  }
  else if (leftMotorInput > 255){
    leftMotorInput = 255;
  }
  if (rightMotorInput < 80){
    rightMotorInput = 80;
  }
  else if (rightMotorInput > 255){
    rightMotorInput = 255;
  }
  
  // Sending the motor inputs to their respective motor
  driveArdumoto(MOTOR_L, leftMotorInput);
  driveArdumoto(MOTOR_R, rightMotorInput);

}

void hitTarget(){
  dist = sqrt(pow((yTarget[counter]-yPosition),2)+pow((xTarget[counter]-xPosition),2));
  
  if (dist < TARGET_THRESHOLD){
    counter ++;
    
    // ask for next target coordinates from the Host computer
    // Need to create XBee transmission commands to ask for this information
  }
}

void printResults(){
  Serial.print(xPosition);
  Serial.print(",");
  Serial.print(yPosition);
  Serial.print(",");
  Serial.print(xTarget[counter]);
  Serial.print(",");
  Serial.print(yTarget[counter]);
  Serial.print(",");
  Serial.print(headingDesired);
  Serial.print(",");
  Serial.print(headingActual);
  Serial.print(",");
  Serial.print(gyroAngleCorrected);
  Serial.print(",");
  Serial.print(theta);
  Serial.print(",");
  Serial.println(output);
}
