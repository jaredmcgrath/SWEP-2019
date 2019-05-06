//leftEncoderTicks is a interrupt service routine that updates the encoder
void leftEncoderTicks(){ // runs in the background updating left encoder value. Never needs to be called
  leftEncoder += (leftInput >= 0) ? 1 : -1;
}

//rightEncoderTicks is a interrupt service routine that updates the encoder
void rightEncoderTicks(){ // runs in the background updating right encoder value. Never needs to be called
  rightEncoder += (rightInput >= 0) ? 1 : -1;
}

//positionCalc is a function that uses the system properties and dynamic equations to estimate the position of the robot (dead reckoning)
//this estimation uses the encoders and the angle of the robot 
void positionCalc(){
  leftRads = (leftEncoder - oldLeftEncoder)*2*PI/192;
  rightRads = (rightEncoder - oldRightEncoder)*2*PI/192;
  xPosition = xPosition + cos(theta)*(0.065/2)*0.5*(leftRads + rightRads);
  yPosition = yPosition + sin(theta)*(0.065/2)*0.5*(leftRads + rightRads);
  oldLeftEncoder = leftEncoder;
  oldRightEncoder = rightEncoder;
}
