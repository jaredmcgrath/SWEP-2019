void checkForIns() {
  byte data;
  byte insId;
  if (XBee.available()) {
    data = XBee.read();
    #if DEBUG
    Serial.println("Instruction received:");
    Serial.println(data, HEX);
    #endif
    insId = getInsId(data);
    // If instuction ID is for this bot, or it is a global instruction
    if (insId == id || insId == ALL_AGENTS) {
      // Truncate the ID bits to 0
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
  // If this is a 2 byte ins, need to isolate instruction and preserve most significant data bit
  if ((ins & 0x10) && (getInsId(ins) != ALL_AGENTS)) {
    msb = ins & 0x1;
    ins = ins & 0x1E;
  }
  switch (ins) {
    case 0x00:
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
      dontGo();
      break;
    case 0x12:
      setX(msb);
      break;
    case 0x14:
      setY(msb);
      break;
    case 0x16:
      setHeading(msb);
      break;
    case 0x18:
      setLeftMotor(msb);
      break;
    case 0x1A:
      setRightMotor(msb);
      break;
    case 0xE0:
      go();
      break;
    case 0xE1:
      reset();
      break;
    case 0xE2:
      confirm();
      break;
    default:
      badResponse();
      break;
  }
}

void go() {
  driveArdumoto(MOTOR_L, leftInput);
  driveArdumoto(MOTOR_R, rightInput);
}

void dontGo() {
  driveArdumoto(MOTOR_L, 0);
  driveArdumoto(MOTOR_R, 0);
}

void badResponse() {
  XBee.write(id<<5);
}

void confirm() {
  XBee.write('K');
  XBee.write((id<<5) | 0x1F);
}

void reset() {
  asm volatile ("  jmp 0");
}

/*
 * All GET responses return data that is at most 13 bits wide
 */
void getX() {
  // Hopefully x fits into the allocated 13 bits
  uint16_t x = (uint16_t)(xPosition*100);
  message[0] = (id<<5) | ((x>>8) & 0x1F);
  message[1] = x & 0xFF;
  XBee.write((char*)message, 2);
}

void getY() {
  // Hopefully y also fits into 13 bits
  uint16_t y = (uint16_t)(yPosition*100);
  message[0] = (id<<5) | (y>>8 & 0x1F);
  message[1] = y & 0xFF;
  XBee.write((char*)message, 2);
}

void getAngle() {
  uint16_t t = theta<0 ? (uint16_t)((theta+2*PI)*180/PI) : (uint16_t)(theta*180/PI);
  #if DEBUG
  Serial.println("Angle in degrees:");
  Serial.println(t);
  #endif
  message[0] = (id<<5) | (t>>8 & 0x1F);
  message[1] = t & 0xFF;
  XBee.write((char*)message, 2);
}

void getLeftTicks() {
  message[0] = (id<<5) | (leftEncoder>>8 & 0x1F);
  message[1] = leftEncoder & 0xFF;
  XBee.write((char*)message, 2);
}

void getRightTicks() {
  message[0] = (id<<5) | (rightEncoder>>8 & 0x1F);
  message[1] = rightEncoder & 0xFF;
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
  // This is not how signed integers work, really. if msb = 0, input is >0. else, input is <0
  leftInput = (msb ? -1 : 1) * getNextByte();
}

void setRightMotor(byte msb) {
  rightInput = (msb ? -1 : 1) * getNextByte();
}

