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

////////////////////////////// Required Pins //////////////////////////////////////////
#define IR_INPUT 11 // Input port for IR transmissions
#define US_INPUT A0 // Input for the US transmission 

////////////////////////////// Receiver Variables /////////////////////////////////
int voltRead; // Ultrasonic pin voltage when a US signal is received
#if DEBUG
int voltReadMax; // Max voltage read during US reception. Must be in DEBUG mode to be enabled
#endif
uint8_t beaconID; // Unique ID. Takes value from 1-NUM BEACONS (should be 5)
bool usTimeoutFlag; // Set to true if system times out before US reception
bool irTimeoutFlag; // Set to true if system times out before IR reception
uint8_t beaconErrorCode = 8; //contains 1-8 depending on localization error. Note that we initialize this to be 8, the "no data received" error code
int beaconDist;

// Timing/distance variable declarations
unsigned long irRecvTime;
unsigned long usRecvTime;
unsigned long beaconStartTime;
unsigned long tdot; // Time difference of transmission
long tdoa; // Time difference of arrival. Signed since it can be a (small) negative due to inaccuracies 
int beaconDistances[NUM_BEACONS]; // [mm] Array of distances to be sent back to MATLAB
uint8_t beaconErrorCodes[NUM_BEACONS]; // Array of error codes associated with distance measurements. To be sent back to MATLAB

///////////////////////////// Object Declaration //////////////////////////////////////
IRrecv irRecv(IR_INPUT); // Set up the Infrared Object to get its data
decode_results irData; // Object for infrared data to be stored and decoded

///////////////////////////// Setup ///////////////////////////////////////////////////
void setup() 
{
  Serial.begin(9600);
  Serial.println(F("Receiver Setup Begin"));
  pinMode(US_INPUT,INPUT);
  irRecv.enableIRIn(); // Starts the IR receiver
  
  #if DEBUG
  Serial.print(F("Enabled IRin (pin #"));
  Serial.print(IR_INPUT);
  Serial.println(F(")"));
  Serial.println();

  Serial.print(F("Ultrasonic pin (pin #"));
  Serial.print(US_INPUT);
  Serial.print(F(") reading a voltage of "));
  Serial.print(analogRead(US_INPUT));
  Serial.println(" [mV-ish]");
  Serial.println();
  #endif
  
  Serial.println(F("Receiver Setup Completed"));
}

///////////////////////////// Main Loop ///////////////////////////////////////////////
void loop() 
{
  beaconRecvData();
  receiverPrint();
}

///////////////////////////// Functions /////////////////////////////////////////////

void beaconRecvData()
{
  irRecvTime = micros();
  if (irRecv.decode(&irData)) // See if there is any IR data that has been decoded
  {
    // If beacon data is not scrambled, beaconID should be 1. Note this value is padded 
    // (added 0xFFFFFFFF before transmission) in order to be 32 bits for IR transmission
    beaconID = 4294967295 - irData.value;

    if (beaconID > 1 && beaconID <= NUM_BEACONS)
    {
      if (micros() - irRecvTime > US_TIMEOUT_THRESHOLD)
      {
        usTimeoutFlag = true;
      }
      voltRead = analogRead(US_INPUT);
    }
    
    usRecvTime = micros(); // US transmission received

    // Find the max voltage for the pulse which triggers US reception
    // (possible that voltRead greater than this quantity due to the time
    // delay taken while executing code)
    #if DEBUG
    while (analogRead(US_INPUT) >= voltReadMax)
    {
      voltReadMax = analogRead(US_INPUT); // Note analogRead takes 100 ms to complete (only approx of max Voltage)
    }
    #endif
    
    // If we have not timed out, continue with signal receiption
    if (!usTimeoutFlag)
    {
      // US and initial IR recieved
      irRecv.resume(); // Receive the next value

      // Wait for second IR transmission
      while ((!irRecv.decode(&irData)) && (!irTimeoutFlag))
      {
        if (micros() - usRecvTime > IR_TIMEOUT_THRESHOLD)
        {
          irTimeoutFlag = true;
        }
      }
        
      // Complete transmission received
      // Subtract the padding (0x80000000) added before transmission to ensure that the transmission is 32 bits
      tdot = irData.value - DATA_PADDING_VALUE;

      // Corrected time difference of arrival, and distance calculations
      tdoa = usRecvTime - irRecvTime - tdot - ZERO_DIST_TIME_DELAY;
      beaconDist = (331 + 0.6 * ambientTemp) * tdoa / 1000; // [mm] Calculate speed of sound based off temp and then calc distance
      }
    }

    // Returns Error code for corresponding error in execution
    if (beaconID < 1 || beaconID > NUM_BEACONS)
    {
      beaconErrorCode = 1;    // Invalid IR beacon ID
    }
    else if (usTimeoutFlag)
    {
      beaconErrorCode = 2;    // Ultrasonic reception timed out
    }
    else if (irTimeoutFlag)
    {
      beaconErrorCode = 3;    // Infrared tdot reception timed out
    }
    else if (tdot > MAX_POSSIBLE_TDOT)    // Time of transmission diffference greater than max possible tdot
    {
      beaconErrorCode = 4;
    }
    else if (tdot < MIN_POSSIBLE_TDOT)    // Time of transmission diffference less than min possible tdot
    {
      beaconErrorCode = 5;
    }
    else if ((usRecvTime - irRecvTime) < tdot )   // US signal received before physically possible
    {
      beaconErrorCode = 6;
    }
    // beaconErrorCode = 7    // Conflicting beacon ID in array. Note that this code is generated elsewhere, but just don't use 7 for something else here!
    // beaconErrorCode = 8    // No data received
    // beaconErrorCode = 9    // Array position not written to
    else    // Success
    {
      beaconErrorCode = 0;
    }

    irRecv.resume(); // Receive the next value
}


void receiverPrint()
{
  // Prints all debug data from a single signal reception
  Serial.println();
  if (beaconErrorCode > 0)
  {
    Serial.print(F("ERROR code #"));
    Serial.print(beaconErrorCode);
    Serial.print(": ");
    switch (beaconErrorCode)
    {
      case 1:
        Serial.print(F("Invalid IR beacon ID (received "));
        Serial.print(beaconID);
        Serial.println(F(")"));
        break;

      case 2:
        Serial.println(F("Ultrasonic reception timed out"));
        break;

      case 3:
        Serial.println(F("Infrared tdot reception timed out"));
        break;

      case 4:
        Serial.print(F("Time of transmission diffference greater than max possible tdot (received: "));
        Serial.print(tdot);
        Serial.print(F(", max possible: "));
        Serial.print(MAX_POSSIBLE_TDOT);
        Serial.println(F(")"));
        break;

      case 5:
        Serial.print(F("Time diffference of transmission less than min possible tdot (received: "));
        Serial.print(tdot);
        Serial.print(F(", min possible: "));
        Serial.print(MIN_POSSIBLE_TDOT);
        Serial.println(F(")"));
        break;

      case 6:
        Serial.println(F("US signal received before physically possible. Consider increasing US_NOMINAL_VOLTAGE_BOUND"));
        break;

      case 7:
        Serial.println(F("Conflict between received beacon ID and beacon ID/distances array. Probably a result of scrambled IR data during beacon ID transmission"));
        break;

      case 8:
        Serial.println(F("Beacon timed out, no data received"));
        break;

      case 9:
        Serial.println(F("Array position not written to"));

      default:
        Serial.println(F("Unhandled error code generated"));
        break;
    }
  }
  else
  {
    Serial.print(F("SUCCESS: "));
    Serial.println(F("Complete transmission received"));
  }
  Serial.print("Beacon ID: ");
  Serial.println(beaconID);
  Serial.print(F("Estimated distance: "));
  Serial.print(beaconDist);
  Serial.println(F("[mm]"));
  Serial.print(F("US trigger voltage read: "));
  Serial.println(voltRead);
  #if DEBUG
  Serial.print(F("Max voltage read: "));
  Serial.println(voltReadMax);
  #endif
  Serial.print(F("Uncorrected TDOA: "));
  Serial.println(usRecvTime - irRecvTime);
  Serial.print(F("Raw tdot transmission: "));
  Serial.println(irData.value);
  Serial.print(F("tdot: "));
  Serial.println(tdot);
  Serial.print(F("tdot corrected TDOA: "));
  Serial.println(tdoa);
  Serial.println();
  Serial.println("___________________________________________________________________________________________________________________________");
  Serial.println();
  Serial.println();
}
