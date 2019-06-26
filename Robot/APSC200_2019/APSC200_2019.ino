/////////////////////////////// Set up the libraries ///////////////////////////////////////////////
// IMPORTANT: "#define NO_PORTD_PINCHANGES" must be before "#include <SoftSerialFix.h>"
#define NO_PORTD_PINCHANGES // to indicate that port d will not be used for pin change interrupts
#include <PinChangeInt.h> //Needed with the above line to have more interrupts that dont interfere with the Xbee --- WAS PinChangeInt.h before, I couldn't find that library, but found PinChangeInterrupt instead
#include <SoftSerialFix.h> //Communication: Needed to create a software serial port for the Xbee
#include "Wire.h"
#include "math.h"
#include <I2Cdev.h> //Sensing/Communication: Needed to have communication to the sensor module
#include <Adafruit_Sensor.h> //Sensing: Needed to get the sensor data from the accel, gyro, compass and temp unit
#include <Adafruit_LSM9DS0.h> //Sensing: Needed to process the specific sensor's (LSM9DS0) raw data into units
#include <IRremote.h>   // Localization: Needed to read received IR patterns

/////////////////////////////// Program Execution Options ///////////////////////////////////////////////
#define DEBUG 0

/////////////////////////////// Program Parameters ///////////////////////////////////////////////
// Localization Parameters
// Constants
#define DATA_PADDING_VALUE 2147483648 // (0x80000000) added before transmission to ensure that the transmission is 32 bits
#define NUM_BEACONS 5 // Number of Beacons
#define ZERO_DIST_TIME_DELAY 22000 // The time delay of the system when taking a measurement from 0mm (it's a fudge factor)
float ambientTemp = 17; // [deg C] will eventually be determined in real-time. Used to make time to distance measurements using the speed of sound more accurate

// Localization Parameters
#define US_NOMINAL_VOLTAGE_BOUND 20   // Unit is (probably) equivalent to 2mV. Any reading greater than this value on the US sensor is deemed to be an incoming US signal
#define US_TIMEOUT_THRESHOLD 400000   // [usec] Number of microseconds waited for US reception before timing out (previously #define US_TIMEOUT_THRESHOLD 250000)
#define IR_TIMEOUT_THRESHOLD 650000  // [usec] Number of microseconds waited for IR reception before timing out (previously 300000)
#define BEACON_TIMEOUT_THRESHOLD 1500000  // [usec] Number of microseconds waited for beacon to ping before timing out
#define MAX_POSSIBLE_TDOT 1500000 // [usec] The largest amount of time it would take for the RPi to send the first IR and then US signal
#define MIN_POSSIBLE_TDOT 50000   // [usec] The shortest amount of time it would take for the RPi to send the first IR and the US signal
#define MOVEMENT_DURATION 1000    // [msec] the amount of time that the robots will drive for before they stop (1000 for 1 second)

/////////////////////////////// Define all needed pins ///////////////////////////////////////////////
#define MOTOR_R 0 // right motor (A)
#define MOTOR_L 1 // left motor (B)
#define ENCODER_R 2   //Encoder pins
#define ENCODER_L 3   //Encoder pins
#define DIRB 7 // Direction control for motor B
#define DIRA 8 // Direction control for motor A
#define PWMA 9  // PWM control (speed) for motor A
#define PWMB 10 // PWM control (speed) for motor B
#define IR_INPUT 11 // Input port for IR Transmission (Localization)
#define US_INPUT A0 // Input for the US Transmission (Localization)
#define BATTERY_PIN A1   // battery level indicator pin. Would be hooked up to votlage divider from 9v barrel jack, but currently not implemented

/////////////////////////////// Sensor Variables ///////////////////////////////////////////////
sensor_t accelSetup, magSetup, gyroSetup, tempSetup; //Variables used to setup the sensor module
sensors_event_t accel, mag, gyro, temp; // Variables to store current sensor event data
float heading, baseline = 0; // Variables to store the calculated heading and the baseline variable (Baseline may be unnecessary)
bool isHeadingSet = false;
// Variables used to calibrate magnetometer
float maxX = 0, maxY = 0, minX = 0, minY = 0;
float magXOffset = 0, magYOffset = 0, magXScale = 1, magYScale = 1;

/////////////////////////////// Encoder Variables ///////////////////////////////////////////////
int oldLeftEncoder = 0, oldRightEncoder = 0; // Stores the encoder value from the loop prior to estimate x, y position
int leftEncoder = 0, rightEncoder = 0; // Stores the encoder values for the current loop
int lastLeftTicks = 0, lastRightTicks = 0; // Ticks upon last call of getLeftTicks/getRightTicks

/////////////////////////////// Position Variables ///////////////////////////////////////////////
float leftRads = 0, rightRads = 0; // Stores the left and right radians of the wheels (from encoder values)
float xPosition = 0, yPosition = 0; // Stores the robot's current x and y position estimate from the encoders
float theta = 0; // Stores the current angle of the robot, from the gyro
float gyroZ; //stores the Z component of the gyroscope so it can be manipulated into an angle
unsigned long oldTime = 0, currentTime = 0; // Variables to timestamp the loops to calculate position

////////////////////////////// Localization Variables ////////////////////////////////////////////
// Localization
int voltRead; // Ultrasonic pin voltage when a US signal is received
#if DEBUG
int voltReadMax; // Max voltage read during US reception. Must be in DEBUG mode to be enabled
#endif
uint8_t beaconID; // Unique ID. Takes value from 1-NUM BEACONS (should be 5)
bool usTimeoutFlag; // Set to true if system times out before US reception
bool irTimeoutFlag; // Set to true if system times out before IR reception
uint8_t beaconErrorCode = 8; //contains 1-8 depending on localization error. Note that we initialize this to be 8, the "no data received" error code

// Timing/distance variable declarations
unsigned long irRecvTime;
unsigned long usRecvTime;
unsigned long beaconStartTime;
long beaconDist;
unsigned long tdot; // Time difference of transmission
long tdoa; // Time difference of arrival. Signed since it can be a (small) negative due to inaccuracies 
int beaconDistances[NUM_BEACONS]; // [mm] Array of distances to be sent back to MATLAB
uint8_t beaconErrorCodes[NUM_BEACONS]; // Array of error codes associated with distance measurements. To be sent back to MATLAB

/////////////////////////////// Other Variables /////////////////////////////////////////////////
int leftInput, rightInput; //A variable to convert the wheel speeds from char (accepted), to int

// Interruptible movement variables
// If Arduino is moving for a fixed duration
bool isMovingFixed = false;
// Clock value to stop movement at
unsigned long endTime;


int startLoop, endLoop; //Loop timing variables to know how long the loop takes
float loopTime;

/////////////////////////////// Agent Tag Data - CHANGE FOR EACH ROBOT ///////////////////////////////////////////////
/*
 * ID's should be numbered 0-6 inclusively
 */
byte message[2];
#define ALL_AGENTS 7
#define ID 2
int id = ID;

////////////////////////////////////////////////////////// Object Declarations //////////////////////////////////////////////////////////
IRrecv irrecv(IR_INPUT); // Set up the Infrared receiver object to get its data
decode_results irData; // An object for the infrared data to be stored and decoded
Adafruit_LSM9DS0 lsm = Adafruit_LSM9DS0(); //An object for the sensor module, to be accessed to get the data
SoftSerialFix XBee(4,5); //The software created serial port to communicate through the Xbee

//////////////////////////////// Setup ////////////////////////////////////////////////////////////


void setup(){
  #if DEBUG 
  Serial.begin(9600);
  #endif
  
  botSetup(); // Set's up Bot configuration
  botCheck(); // Check's that setup was successful and bot is ready to function
  //localizationSetup(); // Performs required setup for Localization Process
  
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
  XBee.begin(9600);      //Set the baud rate for the software serial port
  
  // Ensure sensor module is intact
  if(!lsm.begin()) {
    Serial.print(F("Ooops, no LSM9DS0 detected ... Check your wiring!"));
    while(1);
  }

  // Setup routines
  displaySensorDetails(); //Shows the details about the sensor module, could be removed or put in an if(DEBUG) statement
  configureSensor(); //Configures the sensitivity of the sensor module
  setupArdumoto(); //Sets up the ardumoto shield for the robot's motors
  //localizationSetup(); //Sets up Localization system

  // Pin config
  pinMode(ENCODER_L, INPUT_PULLUP); // Set the mode for the encoder pins
  pinMode(ENCODER_R, INPUT_PULLUP);
  digitalWrite(ENCODER_L, HIGH); //Initialize the state of the encoder pins
  digitalWrite(ENCODER_R, HIGH);
  attachInterrupt(digitalPinToInterrupt(ENCODER_L), leftEncoderTicks, RISING); //assign the interrupt service routines to the pins
  attachInterrupt(digitalPinToInterrupt(ENCODER_R), rightEncoderTicks, RISING); //This is done on the Uno's interrupts pins so this syntax is valid, else use the PCI syntax 

  // Perform magnetometer calibration
  calibrateMagnetometer();
  
  #if DEBUG
  Serial.println(F("botSetup completed"));
  #endif
}

//botCheck enters this check after it has completed all of its setup, it waits here until MATLAB checks that its ready
void botCheck(){
  #if DEBUG
  Serial.println(F("botCheck started"));
  #endif

  // Continue checking for instructions while the heading hasn't been set yet
  // (the heading should be the last variable initialized)
  while(!isHeadingSet){
    delay(20);
    checkForIns();
  }
  getHeading();
  
  #if DEBUG
  Serial.print(F("Inital X ")); Serial.println(xPosition); 
  Serial.print(F("Initial Y ")); Serial.println(yPosition); 
  Serial.println(F("botCheck completed"));
  #endif
}

//The main loop of the robot, could be moved fully to the loop function if desired, on every iteration, x, y, theta are all
//updated by the encoders and the gyro then the Xbee is checked to see if it has any intruction from MATLAB, then the appropriate
//action is performed
void botLoop(){
  // Update orientation
  getHeading();
  // Update bot position using encoders/dead reckoning
  positionCalc();
  // Check for any instructions
  checkForIns();
  // Check if movement should be interrupted
  interruptMovement();
  // Localization procedure
  //localization();
  //delay(500);
}
