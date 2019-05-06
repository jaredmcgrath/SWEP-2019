// setupArdumoto initialize all motor-related pins
void setupArdumoto(){ 
  // All pins should be setup as outputs:
  pinMode(PWMA, OUTPUT);
  pinMode(PWMB, OUTPUT);
  pinMode(DIRA, OUTPUT);
  pinMode(DIRB, OUTPUT);

  // Initialize all pins as low:
  digitalWrite(PWMA, LOW);
  digitalWrite(PWMB, LOW);
  digitalWrite(DIRA, LOW);
  digitalWrite(DIRB, LOW);
}

//stopMotors turns off the motor passed to it, turning both off if the tag both (which is defined at 2) is passed
void stopMotors(byte motor){
  if (motor == 2){
    driveArdumoto(MOTOR_R, 0, agentTag);
    driveArdumoto(MOTOR_L, 0, agentTag);
  }
  else{
    driveArdumoto(motor, 0, agentTag);
  }
}

// driveArdumoto drives 'motor' at speed 'spd'. Negative speeds moves it backwards
void driveArdumoto(byte motor, int spd, char agentTag){ 
  dir = (spd >= 0) ? 1 : 0; 
  spd = (spd >= 0) ? spd : -1*spd;
  if (agentTag == 'S'){
    dir = (dir == 1) ? 0 : 1; // Checks to see if the robot in question is Shannon, if it is then it drives it in the opposit direction since Shannon drives backwards
  }
  if (motor == MOTOR_R){
    digitalWrite(DIRA, dir);
    analogWrite(PWMA, spd);
  }
  else if (motor == MOTOR_L){
    dir = (dir == 1) ? 0 : 1; // direction is flipped on the left motor due to right hand rule
    digitalWrite(DIRB, dir);
    analogWrite(PWMB, spd);
  }  
}

