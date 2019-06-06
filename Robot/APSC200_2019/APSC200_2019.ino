/////////////////////////////// Set up the libraries ///////////////////////////////////////////////
// IMPORTANT: "#define NO_PORTD_PINCHANGES" must be before "#include <SoftSerialFix.h>"
#define NO_PORTD_PINCHANGES // to indicate that port d will not be used for pin change interrupts
#include <PinChangeInt.h> //Needed with the above line to have more interrupts that dont interfere with the Xbee
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
#define MOVEMENT_DURATION 1000      // [msec] The amount of time that the robots will drive for before they stop (1000 for 1 second)

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

/////////////////////////////// Sensor Variables ///////////////////////////////////////////////
sensor_t accelSetup, magSetup, gyroSetup, tempSetup; //Variables used to setup the sensor module
sensors_event_t accel, mag, gyro, temp; // Variables to store the data of the sensors every time it is retrieved
float heading, baseline = 0; // Variables to store the calculated heading and the baseline variable (Baseline may be unnecessary)
bool isHeadingSet = false;

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

/////////////////////////////// Other Variables /////////////////////////////////////////////////
int leftInput, rightInput; //A variable to convert the wheel speeds from char (accepted), to int

int startLoop, endLoop; //Loop timing variables to know how long the loop takes
float loopTime;

/////////////////////////////// Agent Tag Data - CHANGE FOR EACH ROBOT ///////////////////////////////////////////////
/*
 * ID's should be numbered 0-6 inclusively
 */
byte message[2];
byte id = 1;
#define ALL_AGENTS 7

////////////////////////////////////////////////////////// Object Declarations //////////////////////////////////////////////////////////
//IRrecv irrecv(irPin); // Set up the Infrared receiver object to get its data
//decode_results irData; // An object for the infrared data to be stored and decoded
Adafruit_LSM9DS0 lsm = Adafruit_LSM9DS0(); //An object for the sensor module, to be accessed to get the data
SoftSerialFix XBee(4,5); //The software created serial port to communicate through the Xbee

//////////////////////////////// Setup ////////////////////////////////////////////////////////////


void setup(){
  #if DEBUG 
  Serial.begin(9600);
  #endif
  
  botSetup();
  botCheck();
  
  #if DEBUG
  Serial.println(F("\n\nRobot setup complete, beginning main loop\n\n"));
  #endif
}

//////////////////////////////// Main Loop /////////////////////////////////////////////////////////
void loop() {
  /* Code that enables timing analysis for the loop
  startLoop = endLoop;
  endLoop = millis();
  loopTime = (float) (endLoop - startLoop)/1000;
  */
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

  // Pin config
  pinMode(ENCODER_L, INPUT_PULLUP); // Set the mode for the encoder pins
  pinMode(ENCODER_R, INPUT_PULLUP);
  digitalWrite(ENCODER_L, HIGH); //Initialize the state of the encoder pins
  digitalWrite(ENCODER_R, HIGH);
  attachInterrupt(digitalPinToInterrupt(ENCODER_L), leftEncoderTicks, RISING); //assign the interrupt service routines to the pins
  attachInterrupt(digitalPinToInterrupt(ENCODER_R), rightEncoderTicks, RISING); //This is done on the Uno's interrupts pins so this syntax is valid, else use the PCI syntax 
  
  #if DEBUG
  Serial.println(F("botSetup completed"));
  // Bots send a RESP_OK when they've come online
  confirm();
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
  // Bots send a RESP_OK when they've come online
  confirm();
  #endif
}

//The main loop of the robot, could be moved fully to the loop function if desired, on every iteration, x, y, theta are all
//updated by the encoders and the gyro then the Xbee is checked to see if it has any intruction from MATLAB, then the appropriate
//action is performed
void botLoop(){
  //update the angle of the robot
  getHeading();
  positionCalc(); //update the position of the robot
  checkForIns();
//  #if DEBUG
//  Serial.print(F("Angle in Degrees ")); Serial.println(theta); 
//  Serial.print(F("Heading in Degrees ")); Serial.println(heading); 
//  #endif   
  delay(20);
}

