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
//  xPosition and yPosition are set to be the origin of the coordinate system. 
//  theta, the intial heading, is set to be zero degrees
//  Ts is the defined time step for each iteration of robot motion
// NOTE: These variables will need to be intialized at some point during the setup procedure.

void positionCalc(){
  // Calculate the number of ticks that occured over the movement window for each wheel
  leftRads = (leftEncoder - oldLeftEncoder) * 2 * PI / 192;
  rightRads = (rightEncoder - oldRightEncoder) * 2 * PI / 192;

  // Calcualte the x and y position of the robot.
  xPosition = xPosition + cos(theta)*rWheel*0.5*(leftRads+rightRads);
  yPosition = yPosition + sin(theta)*rWheel*0.5*(leftRads+rightRads);

  // calculates the change in theta for the iteration of robot motion.
  theta += (rWheel /(2 * rChasis)) * (rightRads - leftRads);

  theta = theta > 2*PI ? theta - 2*PI : (theta < 0 ? theta + 2*PI : theta);

  oldLeftEncoder = leftEncoder;
  oldRightEncoder = rightEncoder;
  /* 
  OLD CODE
  leftRads = (leftEncoder - oldLeftEncoder)*2*PI/192;
  rightRads = (rightEncoder - oldRightEncoder)*2*PI/192;
  xPosition = xPosition + cos(theta)*(0.065/2)*0.5*(leftRads + rightRads);
  yPosition = yPosition + sin(theta)*(0.065/2)*0.5*(leftRads + rightRads);
  oldLeftEncoder = leftEncoder;
  oldRightEncoder = rightEncoder;
  */
}
