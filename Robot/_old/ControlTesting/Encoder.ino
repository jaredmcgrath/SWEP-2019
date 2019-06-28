/////////////////////////////////// ENCODER FUNCTIONS //////////////////////////////////////////
void Left_Encoder_Ticks(){ // runs in the background updating left encoder value. Never needs to be called
  lCount = (leftWheel >= 0) ? lCount+1 : lCount-1;
  lCount_abs++;

  leftEncoder = lCount;
}
void Right_Encoder_Ticks(){ // runs in the background updating right encoder value. Never needs to be called
  rCount = (rightWheel >= 0) ? rCount+1 : rCount-1;
  rCount_abs++;
  rightEncoder = rCount;
}
void PositionCalc(){
  leftRads = (leftEncoder - oldLeftEncoder)*2*PI/192;
  rightRads = (rightEncoder - oldRightEncoder)*2*PI/192;
  xPosition = xPosition + cos(theta)*(0.065/2)*0.5*(leftRads + rightRads);
  yPosition = yPosition + sin(theta)*(0.065/2)*0.5*(leftRads + rightRads);
  oldLeftEncoder = leftEncoder;
  oldRightEncoder = rightEncoder;
}

