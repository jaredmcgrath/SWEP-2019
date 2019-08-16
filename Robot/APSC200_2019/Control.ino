/*
 * This file contains the files used for the PID control process on the robot. The functions included
 * in this file are:
 *    controlProcess()
 *    hitTarget()
 *    printResults()
 *  
 * These functions are called in botLoop within the APSC200_2019 file. 
 */
// This function controls the motion of the robot such that it reaches its destination target
void controlProcess(){
  // Obtain current time and calculate the time elapsed from the previous run of the function
  currentTime = millis();
  elapsedTime = (float) currentTime - previousTime;

  // Calculate how 'off' the robot's heading is
  headingDesired = atan2((yTarget-yPosition),(xTarget-xPosition));

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
  leftInput = 120 - output/DIVIDER;
  rightInput = 120 + output/DIVIDER;

  // Ensures wheels still rotate and dont slip.
  if (leftInput < 80){
    leftInput = 80;
  }
  else if (leftInput > 255){
    leftInput = 255;
  }
  if (rightInput < 80){
    rightInput = 80;
  }
  else if (rightInput > 255){
    rightInput = 255;
  }
  
  // Sending the motor inputs to their respective motor
  driveArdumoto(MOTOR_L, leftInput);
  driveArdumoto(MOTOR_R, rightInput);

}

void hitTarget(){
  dist = sqrt(pow((yTarget-yPosition),2)+pow((xTarget-xPosition),2));
  
  if (dist < TARGET_THRESHOLD){
    // Stop robot
    done();
    
    // Perform localization to check if the bot's actual position is at the target
    // This is commented out as XBee localization sucks, so we just skip it and go to the next point
//    startLocalization();
//    while (!doneLocalizing) {
//      checkForIns();
//    }
//    #if DEBUG > 0
//    Serial.print("Localized X: "); Serial.println(localX);
//    Serial.print("Localized Y: "); Serial.println(localY);
//    #endif
//    
//    // Update position with localized position. Comment out while testing
////    xPosition = localX;
////    yPosition = localY;
//
//    // Recalculate distance
//    dist = sqrt(pow((yTarget-yPosition),2)+pow((xTarget-xPosition),2));

    // If so, request the next point from host.
    // Otherwise, update the bot's local position with the localized position and continue navigating
    if (dist < TARGET_THRESHOLD) {
      getNextTarget();
    } else {
      hasTarget = true;
    }
  }
}

void printResults(){
  Serial.print(xPosition);
  Serial.print(",");
  Serial.print(yPosition);
  Serial.print(",");
  Serial.print(xTarget);
  Serial.print(",");
  Serial.print(yTarget);
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
