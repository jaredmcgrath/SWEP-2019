/////////////////////////////// Set up the libraries ///////////////////////////////////////////////
#define NO_PORTD_PINCHANGES // to indicate that port d will not be used for pin change interrupts
#include <PinChangeInt.h>
#include <SoftSerialFix.h>
#include "Wire.h"
#include "math.h"
#include <helper_3dmath.h>
//#include <MPU6050.h>
#include <I2Cdev.h>
#include <Adafruit_LSM9DS0.h>
#include <Adafruit_Sensor.h>

/////////////////////////////// Define all needed pins ///////////////////////////////////////////////
#define MOTOR_R 0 // right motor (A)
#define MOTOR_L 1 // left motor (B)
#define both 2 // a tag for both motors
#define DIRA 8 // Direction control for motor A
#define PWMA 9  // PWM control (speed) for motor A
#define DIRB 7 // Direction control for motor B
#define PWMB 10 // PWM control (speed) for motor B
#define PCIpin 12   //test interrupt pin
#define Encoder_Pin_Left 3   //Encoder pins
#define Encoder_Pin_Right 2

/////////////////////////////// Encoder Variables ///////////////////////////////////////////////
long lCount = 0, rCount = 0, lCount_abs, rCount_abs;
int oldLeftEncoder = 0, oldRightEncoder = 0;
int leftEncoder = 0, rightEncoder = 0;

/////////////////////////////// Position Variables ///////////////////////////////////////////////
float leftRads = 0, rightRads = 0;
float xPosition = 0, yPosition = 0;
float theta = 0;
unsigned long oldTime = 0, currentTime = 0;

/////////////////////////////// Other Variables /////////////////////////////////////////////////
char bot;
char response_to_rpi_remote = 'K';
bool first_time = true;
int state, dir;
byte leftInput, rightInput;
int leftWheel = 0, rightWheel = 0;
char leftArray[3], rightArray[3];

int startLoop, endLoop;
float loopTime;
/////////////////////////////// GYROSCOPE FUNCTION CALIBRATION VARIABLES ///////////////////////////////
/*
int gz_offset, mean_gz, ready;
int buffersize=1000;     //Amount of readings used to average, make it higher to get more precision but sketch will be slower  (default:1000)
int acel_deadzone=8;     //Accelerometer error allowed, make it lower to get more precision, but sketch may not converge  (default:8)
int giro_deadzone=1;     //Giro error allowed, make it lower to get more precision, but sketch may not converge  (default:1)
float gyroZ = 0;
*/
Adafruit_LSM9DS0 lsm = Adafruit_LSM9DS0();
sensor_t accelSetup, magSetup, gyroSetup, tempSetup;
sensors_event_t accel, mag, gyro, temp;
float heading, baseline = 0;
/////////////////////////////// Agent Tag Data - CHANGE FOR EACH ROBOT ///////////////////////////////////////////////
char agentTag = 'L';
char agentTagLower = 'l';

//////////////////////////////// Interrupt Service Routines //////////////////////////////////////////////////////////
void interruptCode() {
  state = state + 1;
  Serial.println(state);
}

//////////////////////////////// Setup Variables, Xbee, and Pins //////////////////////////////////////////////////////////
SoftSerialFix XBee(4,5);
//MPU6050 accelgyro(0x68);

void setup(){
  #ifndef ESP8266
    while (!Serial);     // will pause Zero, Leonardo, etc until serial console opens
  #endif
  Serial.begin(9600);
  XBee.begin(9600);
   if(!lsm.begin())
  {
    /* There was a problem detecting the LSM9DS0 ... check your connections */
    Serial.print(F("Ooops, no LSM9DS0 detected ... Check your wiring!"));
    while(1);
  }
  displaySensorDetails();
  configureSensor();

  setupArdumoto();
  pinMode(Encoder_Pin_Left, INPUT_PULLUP);
  pinMode(Encoder_Pin_Right, INPUT_PULLUP);
  digitalWrite(Encoder_Pin_Right, HIGH);
  digitalWrite(Encoder_Pin_Left, HIGH);
  attachInterrupt(digitalPinToInterrupt(Encoder_Pin_Left), Left_Encoder_Ticks, RISING);
  attachInterrupt(digitalPinToInterrupt(Encoder_Pin_Right), Right_Encoder_Ticks, RISING);
  pinMode(PCIpin, INPUT);
  attachPinChangeInterrupt(PCIpin, interruptCode, RISING);
  state = 0;
  //accelgyro.initialize();
  //while (Serial.available() && Serial.read()); // empty buffer
  //accelgyro.setZGyroOffset(0);
}

//////////////////////////////// Main Loop /////////////////////////////////////////////////////////
// loop is the main loop that runs continually after the setup is complete
void loop() {
  if(first_time){
    botCheck();
  }
  
  getWheelInputs(); 
}

//////////////////////////////// Functions /////////////////////////////////////////////////////////
//botCheck checks to make sure that the information being sent is for the correct robot
void botCheck(){
  while(first_time){
    delay(20);
    bot = (XBee.available()) ? char(XBee.read()) : '0';
    if (bot == agentTag){
        XBee.write(agentTag);
        first_time = false;
        getHeading();
        baseline = theta;
        theta = theta - baseline;
        break;
    }
  }
}

//getWheelInputs waits for the Xbee then receives 6 bytes. If the first byte is a B and the fourth byte is an A then it breaks to then drive the motors 
void getWheelInputs() {
  while(true){
    startLoop = endLoop;
    endLoop = millis();
    //Serial.print("start: "); Serial.println(startLoop, 7);
    //Serial.print("end: "); Serial.println(endLoop, 7);
    loopTime = (float) (endLoop - startLoop)/1000;
    //Serial.print("Loop time: "); Serial.println(loopTime, 7);
  
    //thetaCalculation(); //update the angle of the robot
    //getHeading();
    PositionCalc(); //update the position of the robot
    
    Serial.print("Angle in Degrees "); Serial.println(theta);    
    //Serial.print("Omega"); Serial.println(gyroZ);
    delay(20);
    
    bot = (XBee.available()) ? char(XBee.read()) : '0';
    if (bot == agentTag){
        XBee.write(agentTag);
        break;
    }
    if (bot == agentTagLower){
      sendSensors(); //send the x,y,theta position if lower tag is received
    }
  }
    
  int byteCounter = 0;
  while(byteCounter < 3){
    //Serial.println("Here 2");
    if (XBee.available()){
      leftArray[byteCounter] = char(XBee.read());
      byteCounter++;
      delay(20);
    }
  }
  XBee.write('K');
  leftInput = (int) leftArray[2];
  Serial.println(leftArray[0]);
  Serial.println(leftArray[1]);
  Serial.println(leftInput);

  //unnescessary????
  while (XBee.available() && XBee.read()); 
  
  byteCounter = 0;
  while(byteCounter < 3){
    //Serial.println("Here 3");
    if (XBee.available()){
      rightArray[byteCounter] = char(XBee.read());
      byteCounter++;
      delay(20);
    }
  }
  XBee.write('K');
  rightInput = (int) rightArray[2];
  Serial.println(rightArray[0]);
  Serial.println(rightArray[1]);
  Serial.println(rightInput);

  //unnescessary????
  while (XBee.available() && XBee.read());
  
  leftWheel = (int) leftInput;
  rightWheel = (int) rightInput;
  
  if (leftArray[1] == 'N'){
    leftWheel = leftWheel*(-1);
  }
  if (rightArray[1] == 'N'){
    rightWheel = rightWheel*(-1);
  }
  sendInputs(leftWheel, rightWheel);
}

//sendInputs sends the left and right inputs to their appropriate wheels
void sendInputs(int leftWheelInput, int rightWheelInput){
  //thetaCalculation();
  //getHeading();
  driveArdumoto(MOTOR_L, leftWheelInput, agentTag);
  driveArdumoto(MOTOR_R, rightWheelInput, agentTag);
  Serial.println("Motors running");
}

//sendSensors sends the lower case agent tag to the Xbee to let the reciever know where to store the variables, then it sends all of the sensor data (the triangulation sensors)
void sendSensors(){
  XBee.write(agentTagLower); // is a delay needed after this line?
  delay(20); 
  getHeading();
  byte * thetaBytes = (byte *) &theta;
  byte * xBytes = (byte *) &xPosition;
  byte * yBytes = (byte *) &yPosition;
  XBee.write(xBytes,4);
  XBee.write(yBytes,4);
  XBee.write(thetaBytes,4);

  Serial.print("left: ");Serial.println(leftEncoder);
  Serial.print("right: ");Serial.println(rightEncoder);
  Serial.print("x: ");Serial.println(xPosition);
  Serial.print("y: ");Serial.println(yPosition);
 // Serial.print("gyro: ");Serial.println(gyroZ);
  Serial.print("theta: ");Serial.println(theta);
 
}

