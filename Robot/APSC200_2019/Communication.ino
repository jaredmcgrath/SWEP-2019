void checkForIns() {
  byte data;
  byte insId;
  if (XBee.available()) {
    data = XBee.read();
    insId = getInsId(data);
    #if DEBUG
    Serial.print("Instruction received: "); Serial.println(data, HEX);
    Serial.print("id: "); Serial.println(insId);
    #endif
    // If instuction id is for this bot
    if (insId == id) {
      // Mask the instruction so id bits are 0
      executeIns(data & 0x1F);
    }
    // If instruction is for all bots
    else if (insId == ALL_AGENTS) {
      // Send whole instruction
      executeIns(data);
    }
    // If the instruction is 2 bytes, cycle the XBee until second byte is read and discarded
    else if (data & 0x10) {
      while(!XBee.available());
      XBee.read();
    }
  }
}

byte getInsId(byte ins) {
  // This could be done in one line, but I'm leaving it for extensibility in the future
  byte rslt = ins & 0xE0;
  rslt = rslt >> 5;
  return rslt;
}

/*
 * A note on extensibility of the communication protocol:
 * There is room for:
 *  - 32 global instructions
 *  - 32 bot-specific instructions WITHOUT data
 *  - 8 bot-specific instructions WITH data (it could be 16 if I was less lazy, but there would be more coding involved)
 *  
 *  In the current version of this protocol (first revision, no localization), there are 3 globals, 8 w/o data, 5 w/ data
 *  See the spreadsheet for details
 */
void executeIns(byte ins) {
  byte msb = 0;
  // If this is a 2 byte, single bot instruction, need to isolate instruction and preserve most significant data bit
  if ((ins & 0x10) && (getInsId(ins) != ALL_AGENTS)) {
    msb = ins & 0x1;
    ins = ins & 0x1E;
    #if DEBUG
      Serial.print("2 byte instruction. Actual ins: "); Serial.println(ins);
    #endif
  }
  // If this is a 2 byte, global instruction, isolate instruction and preserve MSB
  else if (ins & 0x10) {
    msb = ins & 0x1;
    ins = ins & 0xFE;
  }
  switch (ins) {
    case 0x00:
      confirm();
      go();
      break;
    case 0x01:
      getX();
      break;
    case 0x02:
      getY();
      break;
    case 0x03:
      getAngle();
      break;
    case 0x04:
      getLeftTicks();
      break;
    case 0x05:
      getRightTicks();
      break;
    case 0x06:
      getBattery();
      break;
    case 0x07:
      // apparently stop is a reserved word
      confirm();
      dontGo();
      break;
    case 0x12:
      setX(msb);
      confirm();
      break;
    case 0x14:
      setY(msb);
      confirm();
      break;
    case 0x16:
      setHeading(msb);
      confirm();
      break;
    case 0x18:
      setLeftMotor(msb);
      confirm();
      break;
    case 0x1A:
      setRightMotor(msb);
      confirm();
      break;
    case 0x1C:
      confirm();
      goFixed(msb);
      break;
    case 0xE0:
      confirm();
      go();
      break;
    case 0xE1:
      confirm();
      reset();
      break;
    case 0xE2:
      confirm();
      break;
    case 0xE3:
      confirm();
      dontGo();
      break;
    case 0xE4:
      getX();
      break;
    case 0xE5:
      getY();
      break;
    case 0xE6:
      getAngle();
      break;
    case 0xF0:
      confirm();
      goFixed(msb);
      break;
    default:
      #if DEBUG
        Serial.println("Bad instruction");
      #endif
      //badResponse();
      break;
  }
}

void go() {
  #if DEBUG
    Serial.println("Going");
  #endif
  driveArdumoto(MOTOR_L, leftInput);
  driveArdumoto(MOTOR_R, rightInput);
}

void dontGo() {
  driveArdumoto(MOTOR_L, 0);
  driveArdumoto(MOTOR_R, 0);
}

void badResponse() {
  #if DEBUG
    Serial.print("Bad response, sending "); Serial.println(id<<5);
  #endif
  XBee.write(id<<5);
}

void confirm() {
  #if DEBUG
    Serial.print("Confirm response, sending "); Serial.println((id<<5) | 0x1F);
  #endif
  XBee.write((id<<5) | 0x1F);
}

void reset() {
  asm volatile ("  jmp 0");
}
/*
 * All GET responses return data that is at most 13 bits wide
 */
void getX() {
  // x is a 13-bit 2's complement signed integer
  uint16_t x;
  if (xPosition < 0) {
    // Take magnitude of x*100, put into uint16, perform bitwise complement, truncate leading 3 bits, and add 1
    x = (~((uint16_t)(-100*xPosition)) & 0x1FFF) + 1;
  } else {
    x = (uint16_t)(xPosition*100);
  }
  #if DEBUG
  Serial.print("X value, bin: "); Serial.println(x, BIN);
  #endif
  message[0] = (id<<5) | ((x>>8) & 0x1F);
  message[1] = x & 0xFF;
  XBee.write((char*)message, 2);
}

void getY() {
  // y is a 13-bit 2's complement signed integer
  uint16_t y;
  if (yPosition < 0) {
    // Take magnitude of y*100, put into uint16, perform bitwise complement, truncate leading 3 bits, and add 1
    y = (~((uint16_t)(-100*yPosition)) & 0x1FFF) + 1;
  } else {
    y = (uint16_t)(yPosition*100);
  }
  message[0] = (id<<5) | (y>>8 & 0x1F);
  message[1] = y & 0xFF;
  XBee.write((char*)message, 2);
}

void getAngle() {
  //uint16_t t = theta<0 ? (uint16_t)((theta+2*PI)*180/PI) : (uint16_t)(theta*180/PI);
  uint16_t t = (uint16_t) (theta*180/PI);
  #if DEBUG
  Serial.println("Angle in degrees:");
  Serial.println(t);
  #endif
  // This number should always be unsigned integer < 360, so only need 9 bits
  message[0] = (id<<5) | (t>>8 & 0x01);
  message[1] = t & 0xFF;
  XBee.write((char*)message, 2);
}

void getLeftTicks() {
  int ticks = abs(leftEncoder - lastLeftTicks);
  lastLeftTicks = leftEncoder;
  message[0] = (id<<5) | (ticks>>8 & 0x1F);
  message[1] = ticks & 0xFF;
  XBee.write((char*)message, 2);
}

void getRightTicks() {
  int ticks = abs(rightEncoder - lastRightTicks);
  lastRightTicks = rightEncoder;
  message[0] = (id<<5) | (ticks>>8 & 0x1F);
  message[1] = ticks & 0xFF;
  XBee.write((char*)message, 2);
}

void getBattery() {
  uint16_t b = analogRead(BATTERY_PIN);
  message[0] = (id<<5) | (b>>7 & 0x1F);
  message[1] = b & 0xFF;
  XBee.write((char*)message, 2);
}

/*
 * All SET instructions will need to read the second data byte from XBee
 */
byte getNextByte() {
  while(!XBee.available());
  byte nextByte = XBee.read();
  #if DEBUG
  Serial.println("Second byte received:");
  Serial.println(nextByte);
  #endif
  return nextByte;
}
 
void setX(byte msb) {
  uint16_t x = msb<<8 | getNextByte();
  xPosition = x/100.0;
}

void setY(byte msb) {
  uint16_t y = msb<<8 | getNextByte();
  yPosition = y/100.0;
}

void setHeading(byte msb) {
  uint16_t h = msb<<8 | getNextByte();
  baseline = h>180 ? (h-360)*PI/180 : h*PI/180;
  #if DEBUG
  Serial.println("Heading set");
  Serial.println(baseline);
  #endif
  // IMPORTANT: Setting isHeadingSet true allows botCheck to complete
  isHeadingSet = true;
}

void setLeftMotor(byte msb) {
  leftInput = (msb ? -1 : 1) * getNextByte();
}

void setRightMotor(byte msb) {
  rightInput = (msb ? -1 : 1) * getNextByte();
}

void goFixed(byte msb) {
  // Get duration of movement (data value is in centiseconds)
  uint16_t duration = (msb<<8 | getNextByte())*10;
  // Drive the motors
  driveArdumoto(MOTOR_L, leftInput);
  driveArdumoto(MOTOR_R, rightInput);
  // Calculate endtime
  endTime = millis() + duration;
  // Set to true to indicate it needs to be stopped in future
  isMovingFixed = true;
}

