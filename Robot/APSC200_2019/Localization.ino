///////////////LOCALIZATION///////////
//
///*
//This is the code I tried writing on JUNE 13, 2019 for the localization before receiving Hugh's code from 2018
//// US Input at ANALOG INPUT Pin 0
//// IR Input at DIGITAL INPUT Pin 11
//
//int calcDistance(void)
//{
//  // The idea here is that it checks if a transmission has been recieved from a beacon
//  // if an IR transmission is recieved then it will wait for the paired US signal to arrive
//  // PROBLEMS: Have it wait for a signal to arrive? A delay/wait of some sort?
//  //           How to differentiate between which beacon is transmitting?
//  //              (xbee indicate, ir signal indicator, both (as a check)?) 
//
//  int waitTimer = 5; // defines how long program waits for an IR input
//  unsigned long timeStart = millis(); // time before program begins waiting for IR transmission
//  unsigned long timeIRArrival = timeStart; // time when IR transmission arrives
//  
//  // Wait 5 milliseconds for an IR transmission to be recieved.
//  while(digitalRead(IR_INPUT)== LOW && timeIRArrival < timeStart + waitTimer)
//  {
//    timeIRArrival = millis();
//  }
//
//  // Runs if IR transmission was recieved
//  if (timeIRArrival < timeStart + waitTimer)
//  {
//    analogRead(US_INPUT);  
//    unsigned long timeDifferenceOfArrival = millis() - timeIRArrival; //calculates in milliseconds the time difference between the IR signal and the US signal arriving
//    return dist = (float)343*timeDifferenceOfArrival;
//  }
//  else
//  {
//    return 0;
//  }
//}
//*/
//
////////////////////////HUGH'S LOCALIZATION CODE///////////////////////////
//
//void localizationSetup()
//{
//  #if DEBUG
//  Serial.println(F("localizationSetup started"));
//  #endif
//  
//  // Set US pin
//  pinMode(US_INPUT, INPUT);
//
//  // IR setup
//  #if DEBUG
//  Serial.println(F("Enabling IRin"));
//  #endif
//  
//  irrecv.enableIRIn(); // Start the receiver
//  
//  #if DEBUG
//  Serial.print(F("Enabled IRin (pin #"));
//  Serial.print(IR_INPUT);
//  Serial.println(F(")"));
//  Serial.println();
//
//  Serial.print(F("Ultrasonic pin (pin #"));
//  Serial.print(US_INPUT);
//  Serial.print(F(") reading a voltage of "));
//  Serial.print(analogRead(US_INPUT));
//  Serial.println(" [mV-ish]");
//  Serial.println();
//
//  Serial.println(F("localizationSetup completed"));
//  #endif
//}
//
//
//// Populates the beaconErrorCodes and beaconDistances arrays by calling beaconRecvData which receives transmission from a particular beacon
//void localization()
//{
//  // Write all elements in the array of beacon distances to be zero, and the error codes to be unwritten
//  // This array is what will be sent back to MATLAB
//  for (int i = 0; i < NUM_BEACONS ; i++)
//  {
//    beaconErrorCodes[i] = 9;    // Reset all error codes to be 9 (unwritten) at first
//    beaconDistances[i] = 0;
//  }
//
//  for (int i = 0; i < NUM_BEACONS ; i++)
//  {
//    beaconStartTime = micros();
//    // Wait until data is received, or we time out. Note that beaconErrorCode is defined to be 8 at first
//    while ((micros() - beaconStartTime < BEACON_TIMEOUT_THRESHOLD) && (beaconErrorCode == 8))   
//    {
//      beaconRecvData();
//    }
//
//    if (beaconErrorCode != 1 && beaconErrorCode != 8) // If the beaconID is valid, and beaconRecvData did not time out (ie. we have some sort of data we want to put in the beaconDistances and beaconErrorCodes arrays)
//    {
//      if (beaconErrorCodes[beaconID - 1] == 9)   // If the array element is unwritten, then we do not have a conflict. Write to the array
//      {
//        beaconErrorCodes[beaconID - 1] = beaconErrorCode;
//        beaconDistances[beaconID - 1] = beaconDist;
//      }
//      else    // If the array element does not have an "unwritten" error code (ie. a previous, or the current beacon ID was scrambled) then set the error code to 7 (conflict)
//      {
//        beaconErrorCodes[beaconID - 1] = 7;   // Conflict between received beacon ID and beacon ID/distances array. Probably a result of scrambled IR data during beacon ID transmission
//        beaconDistances[beaconID - 1] = 0;
//      }
//    }
//    
//
//    #if DEBUG
//    localizationPrint();    // Print the debug data associated with a single signal reception
//    #endif
//    localizationResetVar();   // Reset some variables and flags used in signal reception
//
//    while (micros() - beaconStartTime < BEACON_TIMEOUT_THRESHOLD)
//    {
//      ;   // Loop until BEACON_TIMEOUT_THRESHOLD so that we stay in sync with the beacons pinging
//    }
//  }
//
//  #if DEBUG
//  localizationPrintArray();   // Print the results of the 5 element arrays beaconDistances, beaconErrorCodes
//  #endif
//}
//
//
//// Receives data from a particular beacon
//void beaconRecvData()
//{
//  irRecvTime = micros();
//  if (irrecv.decode(&irData))   // See if there is any IR data that has been decoded
//  {
//    // If IR data is not scrambled, beaconID should be between 1 and 5. Note that this value is padded (added 0xFFFFFFFF before transmission) in order to be 32 bits for IR transmission
//    beaconID = 4294967295 - irData.value;
//
//    // If the beacon ID is valid (ie. falls between 1 and 5, wait for ultrasonic and a second IR pulse
//    if (beaconID > 0 && beaconID <= NUM_BEACONS)
//    {
//
//      // wait for US receiption. Loop while the voltage of the US pin is within the bound of nominal, and we have not yet timed out
//      voltRead = analogRead(US_INPUT);
//      while (voltRead < US_NOMINAL_VOLTAGE_BOUND && !usTimeoutFlag)
//      {
//        if (micros() - irRecvTime > US_TIMEOUT_THRESHOLD)
//        {
//          usTimeoutFlag = true;
//        }
//        voltRead = analogRead(US_INPUT);
//      }
//      // US transmission received!
//      usRecvTime = micros();
//
//      // Find the max voltage for the pulse which triggers ultrasonic reception (it is possible that voltRead is greater than this quantity due to the the time delay taken while executing code)
//      #if DEBUG
//      while (analogRead(US_INPUT) >= voltReadMax)
//      {
//        voltReadMax = analogRead(US_INPUT);    // Note that the analogRead operation takes around 100 microseconds to complete. Thus, the voltReadMax is only a very rough approximation of what the maximum might be
//      }
//      #endif
//
//      // If we have not timed out, continue with signal receiption
//      if (!usTimeoutFlag)
//      {
//        // US and initial IR recieved
//        irrecv.resume(); // Receive the next value
//
//        // Wait for second IR transmission
//        while ((!irrecv.decode(&irData)) && (!irTimeoutFlag))
//        {
//          if (micros() - usRecvTime > IR_TIMEOUT_THRESHOLD)
//          {
//            irTimeoutFlag = true;
//          }
//        }
//        // Complete transmission received
//        // Subtract the padding (0x80000000) added before transmission to ensure that the transmission is 32 bits
//        tdot = irData.value - DATA_PADDING_VALUE;
//
//        // Corrected time difference of arrival, and distance calculations
//        tdoa = usRecvTime - irRecvTime - tdot - ZERO_DIST_TIME_DELAY;
//        beaconDist = (331 + 0.6 * ambientTemp) * tdoa / 1000; // [mm] Calculate speed of sound based off temp and then calc distance
//      }
//    }
//
//    if (beaconID < 1 || beaconID > NUM_BEACONS)
//    {
//      beaconErrorCode = 1;    // Invalid IR beacon ID
//    }
//    else if (usTimeoutFlag)
//    {
//      beaconErrorCode = 2;    // Ultrasonic reception timed out
//    }
//    else if (irTimeoutFlag)
//    {
//      beaconErrorCode = 3;    // Infrared tdot reception timed out
//    }
//    else if (tdot > MAX_POSSIBLE_TDOT)    // Time of transmission diffference greater than max possible tdot
//    {
//      beaconErrorCode = 4;
//    }
//    else if (tdot < MIN_POSSIBLE_TDOT)    // Time of transmission diffference less than min possible tdot
//    {
//      beaconErrorCode = 5;
//    }
//    else if ((usRecvTime - irRecvTime) < tdot )   // US signal received before physically possible
//    {
//      beaconErrorCode = 6;
//    }
//    // beaconErrorCode = 7    // Conflicting beacon ID in array. Note that this code is generated elsewhere, but just don't use 7 for something else here!
//    // beaconErrorCode = 8    // No data received
//    // beaconErrorCode = 9    // Array position not written to
//    else    // Success
//    {
//      beaconErrorCode = 0;
//    }
//
//    irrecv.resume(); // Receive the next value
//  }
//}
//
//
//void localizationPrint()
//{
//  // Prints all debug data from a single signal reception
//  Serial.println();
//  if (beaconErrorCode > 0)
//  {
//    Serial.print(F("ERROR code #"));
//    Serial.print(beaconErrorCode);
//    Serial.print(": ");
//    switch (beaconErrorCode)
//    {
//      case 1:
//        Serial.print(F("Invalid IR beacon ID (received "));
//        Serial.print(beaconID);
//        Serial.println(F(")"));
//        break;
//
//      case 2:
//        Serial.println(F("Ultrasonic reception timed out"));
//        break;
//
//      case 3:
//        Serial.println(F("Infrared tdot reception timed out"));
//        break;
//
//      case 4:
//        Serial.print(F("Time of transmission diffference greater than max possible tdot (received: "));
//        Serial.print(tdot);
//        Serial.print(F(", max possible: "));
//        Serial.print(MAX_POSSIBLE_TDOT);
//        Serial.println(F(")"));
//        break;
//
//      case 5:
//        Serial.print(F("Time diffference of transmission less than min possible tdot (received: "));
//        Serial.print(tdot);
//        Serial.print(F(", min possible: "));
//        Serial.print(MIN_POSSIBLE_TDOT);
//        Serial.println(F(")"));
//        break;
//
//      case 6:
//        Serial.println(F("US signal received before physically possible. Consider increasing US_NOMINAL_VOLTAGE_BOUND"));
//        break;
//
//      case 7:
//        Serial.println(F("Conflict between received beacon ID and beacon ID/distances array. Probably a result of scrambled IR data during beacon ID transmission"));
//        break;
//
//      case 8:
//        Serial.println(F("Beacon timed out, no data received"));
//        break;
//
//      case 9:
//        Serial.println(F("Array position not written to"));
//
//      default:
//        Serial.println(F("Unhandled error code generated"));
//        break;
//    }
//  }
//  else
//  {
//    Serial.print(F("SUCCESS: "));
//    Serial.println(F("Complete transmission received"));
//  }
//  Serial.print("Beacon ID: ");
//  Serial.println(beaconID);
//  Serial.print(F("Estimated distance: "));
//  Serial.print(beaconDist);
//  Serial.println(F("[mm]"));
//  Serial.print(F("US trigger voltage read: "));
//  Serial.println(voltRead);
//  #if DEBUG
//  Serial.print(F("Max voltage read: "));
//  Serial.println(voltReadMax);
//  #endif
//  Serial.print(F("Uncorrected TDOA: "));
//  Serial.println(usRecvTime - irRecvTime);
//  Serial.print(F("Raw tdot transmission: "));
//  Serial.println(irData.value);
//  Serial.print(F("tdot: "));
//  Serial.println(tdot);
//  Serial.print(F("tdot corrected TDOA: "));
//  Serial.println(tdoa);
//  Serial.println();
//  Serial.println("___________________________________________________________________________________________________________________________");
//  Serial.println();
//  Serial.println();
//}
//
//
//void localizationResetVar()
//{
//
//  beaconErrorCode = 8;    // Set error code to no data received
//  #if DEBUG
//  voltReadMax = 0;
//  #endif
//
//  // Reset flags
//  usTimeoutFlag = false;
//  irTimeoutFlag = false;
//}
//
//void localizationPrintArray()
//{
//  for (int i = 0; i < NUM_BEACONS ; i++)
//  {
//    Serial.print(F("Beacon "));
//    Serial.println(i + 1);
//    Serial.print(F("Distance: "));
//    Serial.print(beaconDistances[i]);
//    Serial.println(F(" [mm]"));
//    Serial.print(F("Error code: "));
//    Serial.println(beaconErrorCodes[i]);
//    Serial.println();
//  }
//  Serial.println(F("___________________________________________________________________________________________________________________________"));
//  Serial.println();
//  Serial.println();
//}
