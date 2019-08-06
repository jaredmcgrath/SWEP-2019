// setupArdumoto puts all of the pins as output pins and initializes them as low
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

// driveArdumoto sets the motor at a certain speed, negative speeds moves it backwards and if the robot is Shannon, then it reverses the speed of the wheel
void driveArdumoto(byte motor, int spd){
  #if DEBUG > 0
    Serial.print("Motor "); Serial.print(motor); Serial.print(" at speed "); Serial.println(spd);
  #endif
  int dir = (spd >= 0) ? 1 : 0;
  spd = (spd >= 0) ? spd : -1*spd;

  // Correct shannon going backwards
  if (id == 0)
    dir = dir ? 0 : 1;
  
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
