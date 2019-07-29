/**
 * checkForIns() is to be called in the main loop. The call to XBee::readPacket() may or may not
 * return a response, depending on whether the XBee's internal Stream _serial reference indicates
 * a packet is available to be read.
 * 
 * If a packet is read, the switch-case block casts the generic response to the correct response
 * subclass, then calls the corresponding function to handle such a response. These callbacks will
 * reference the global objects declared before program begins.
 */
void checkForIns() {
  xbee.readPacket();
  if (xbee.getResponse().isAvailable()) {
    xbee.getResponse(response);
    switch (response.getApiId()) {
      // Case of a 16-bit address response
      case RX_16_RESPONSE:
        response.getRx16Response(rx16);
        handleRx16();
        break;
      // Case of a tx status response, after this xbee transmits a frame.
      case TX_STATUS_RESPONSE:
        response.getTxStatusResponse(txStatus);
        handleStatusResponse();
        break;
    }
    response.reset();
  } else if (xbee.getResponse().isError()) {
    // Handle the error
    handleError(xbee.getResponse().getErrorCode());
  }
}

/**
 * Callback to handle all Rx16Responses received on the XBee. The response should be located in rx16
 */
void handleRx16() {
  // Get the frame data length
  uint8_t dataLength = rx16.getDataLength();
  // Get reference to frame data
  // Frame data includes
  uint8_t *data = rx16.getData();
  // Get RSSI (not needed though)
  uint8_t rssi = rx16.getRssi();
  
  #if DEBUG
//  Serial.print(F("Error: ")); Serial.println(rx16.getErrorCode());
//  Serial.print(F("API ID: ")); Serial.println(rx16.getApiId(),HEX);
//  Serial.print(F("MSB Length: ")); Serial.println(rx16.getMsbLength(),HEX);
//  Serial.print(F("LSB Length: ")); Serial.println(rx16.getLsbLength(),HEX);
//  Serial.print(F("Checksum: ")); Serial.println(rx16.getChecksum(),HEX);
//  Serial.print(F("Frame data length: ")); Serial.println(rx16.getFrameDataLength(),HEX);
//  Serial.print(F("Packet Length: ")); Serial.println(rx16.getPacketLength(), HEX);
//
//  Serial.println("Data:");
//  for (int i = 0; i < dataLength; i++) {
//    for (byte mask = 0x80; mask; mask >>= 1) {
//      if (mask & *(data+i))
//        Serial.print(1);
//      else
//        Serial.print(0);
//    }
//    Serial.print(" ");
//  }
//  for (int i = 0; i < dataLength; i++) {
//    Serial.print(*(data+i),HEX); Serial.print(" ");
//  }
//  Serial.println();
  Serial.println(F("Rx16 Received"));
  #endif
  
  // Get the instruction
  uint8_t instruction = *data;
  // Increment pointer to data 
  data++;
  // Decrement dataLength by 1
  dataLength--;
  // Execute the instruction
  executeInstruction(instruction, data, dataLength);
  rx16.reset();
}

void handleStatusResponse() {
  #if DEBUG
  if (txStatus.getStatus() == SUCCESS) {
    Serial.println(F("Successful tx"));
  } else {
    Serial.println(F("Unsuccessful tx"));
  }
  #endif
}

void handleError(uint8_t error) {
  #if DEBUG
  Serial.print(F("Received XBee Error! Code: "));
  Serial.println(error, HEX);
  #endif
}

void sendTx16Request(uint8_t *payload, uint8_t payloadLength) {
  #if DEBUG
  Serial.println(F("Sending Tx16"));
  #endif
  tx = Tx16Request(DEST_ADDRESS, payload, payloadLength);
  // TODO: Figure out if we need to check for status response
  xbee.send(tx);
}

void executeInstruction(uint8_t instruction, uint8_t *data, uint8_t dataLength) {
  switch (instruction) {
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
      dontGo();
      break;
    case 0x08:
      getPos();
      break;
    case 0x09:
      // We expect only one uint8 to be sent as data, indicating how many beacons will ping
      startRssi(*data);
      break;
    case 0x0A:
      nextBeacon();
      break;
    // SET instructions
    case 0x80:
      setX(bytesToFloat(data, dataLength));
      break;
    case 0x81:
      setY(bytesToFloat(data, dataLength));
      break;
    case 0x82:
      setAngle(bytesToFloat(data, dataLength));
      break;
    case 0x83:
      setLeftMotor(bytesToInt16(data, dataLength));
      break;
    case 0x84:
      setRightMotor(bytesToInt16(data, dataLength));
      break;
    case 0x85:
      goFixed(bytesToULong(data, dataLength));
      break;
    case 0x86:
      if (dataLength == 12) {
        setPos(bytesToFloat(data, 4), bytesToFloat(data+4, 4), bytesToFloat(data+8, 4));
      }
      #if DEBUG
      else {
        Serial.println("SET_POS failed!");
      }
      #endif
      break;
    default:
      #if DEBUG
        Serial.println("Bad instruction");
      #endif
      break;
  }
}

/*
 * Functions to get the proper data type from byte array
 */

float bytesToFloat(uint8_t *data, uint8_t dataLength) {
  if (data && dataLength == 4) {
    // We use the union type defined in the main file to construct a float from byte array
    // This assumes everything is little endian
    ByteArray4 ba;
    for (int i = 0; i < 4; i++) {
      ba.b[i] = *(data + i);
    }
    return ba.f;
  } else {
    return 0;
  }
}

int16_t bytesToInt16(uint8_t *data, uint8_t dataLength) {
  if (data && dataLength == 2) {
    ByteArray2 bi;
    bi.b[0] = *data;
    bi.b[1] = *(data+1);
    return bi.int16;
  } else {
    return 0;
  }
}

unsigned long bytesToULong(uint8_t *data, uint8_t dataLength) {
  if (data && dataLength == 4) {
    // We use the union type defined in the main file to construct an unsigned long from byte array
    // This assumes everything is little endian
    ByteArray4 ba;
    for (int i = 0; i < 4; i++)
      ba.b[i] = *(data + i);
    return ba.uLong;
  } else {
    return 0;
  }
}

/*
 * Executable instructions
 */

void go() {
  driveArdumoto(MOTOR_L, leftInput);
  driveArdumoto(MOTOR_R, rightInput);
  #if DEBUG
  Serial.print(F("Going with left motor at ")); Serial.print(leftInput); Serial.print(F(", right motor at ")); Serial.println(rightInput);
  #endif
}

void dontGo() {
  driveArdumoto(MOTOR_L, 0);
  driveArdumoto(MOTOR_R, 0);
  #if DEBUG
  Serial.println(F("Stopped"));
  #endif
}

void getX() {
  // Create payload of 5 bytes
  uint8_t payload[5];
  ByteArray4 ba;
  // First byte is the instruction, 0x01
  payload[0] = 0x01;
  ba.f = xPosition;
  // Remaining 4 bytes are the float
  for (int i = 0; i < 4; i++)
    payload[i+1] = ba.b[i];
  // Send the payload
  sendTx16Request(payload, 5);
  #if DEBUG
  Serial.print(F("Sending X of: ")); Serial.println(ba.f);
  #endif
}

void getY() {
  // Create payload of 5 bytes
  uint8_t payload[5];
  ByteArray4 ba;
  // First byte is the instruction, 0x02
  payload[0] = 0x02;
  ba.f = yPosition;
  // Remaining 4 bytes are the float
  for (int i = 0; i < 4; i++)
    payload[i+1] = ba.b[i];
  // Send the payload
  sendTx16Request(payload, 5);
  #if DEBUG
  Serial.print(F("Sending Y of: ")); Serial.println(ba.f);
  #endif
}

void getAngle() {
  // Create payload of 5 bytes
  uint8_t payload[5];
  ByteArray4 ba;
  // First byte is the instruction, 0x03
  payload[0] = 0x03;
  ba.f = theta;
  // Remaining 4 bytes are the float
  for (int i = 0; i < 4; i++)
    payload[i+1] = ba.b[i];
  // Send the payload
  sendTx16Request(payload, 5);
  #if DEBUG
  Serial.print(F("Sending angle of: ")); Serial.println(ba.f);
  #endif
}

void getLeftTicks() {
  ByteArray2 ba;
  ba.int16 = abs(leftEncoder - lastLeftTicks);
  lastLeftTicks = leftEncoder;
  // Create payload of 3 bytes
  uint8_t payload[3];
  // First byte is the instruction, 0x04
  payload[0] = 0x04;
  // Remaining 2 bytes are the int16
  for (int i = 0; i < 2; i++)
    payload[i+1] = ba.b[i];
  // Send the payload
  sendTx16Request(payload, 3);
  #if DEBUG
  Serial.print(F("Sending left ticks of: ")); Serial.println(ba.int16);
  #endif
}

void getRightTicks() {
  ByteArray2 ba;
  ba.int16 = abs(rightEncoder - lastRightTicks);
  lastRightTicks = rightEncoder;
  // Create payload of 5 bytes
  uint8_t payload[3];
  // First byte is the instruction, 0x05
  payload[0] = 0x05;
  // Remaining 2 bytes are the int16
  for (int i = 0; i < 2; i++)
    payload[i+1] = ba.b[i];
  // Send the payload
  sendTx16Request(payload, 3);
  #if DEBUG
  Serial.print(F("Sending right ticks of: ")); Serial.println(ba.int16);
  #endif
}

void getBattery() {
  #if DEBUG
  Serial.println(F("Unimplemented GET_B call!"));
  #endif
//  uint16_t b = analogRead(BATTERY_PIN);
//  // Not 100% sure yet how well this works
//  uint8_t payload[3];
//  payload[0] = 0x06;
//  // Remaining 2 bytes are the uint16_t
//  for (int i = 0; i < 4; i++)
//    payload[i+1] = *(&b + i);
//  // Send the payload
//  sendTx16Request(payload, 3);
}

void getPos() {
  // Position data struct that is easily convertible to byte array
  ByteArray16 bp;
  // Create payload of 17 bytes
  uint8_t payload[17];
  // First byte is instruction
  payload[0] = 0x08;
  // Disable interrupts for timing accuracy
  noInterrupts();
  bp.posStruct.x = xPosition;
  bp.posStruct.y = yPosition;
  bp.posStruct.a = theta;
  bp.posStruct.t = millis();
  // Enable interrupts
  interrupts();
  // Put data in payload
  for (int i = 0; i < 16; i++) {
    payload[i+1] = bp.b[i];
  }
  // Send the payload
  sendTx16Request(payload, 17);
  #if DEBUG
  Serial.println(F("GET_POS Data sent"));
  #endif
}
 
void setX(float x) {
  xPosition = x;
  #if DEBUG
  Serial.print(F("X Position set to: ")); Serial.println(xPosition);
  #endif
}

void setY(float y) {
  yPosition = y;
  #if DEBUG
  Serial.print(F("Y Position set to: ")); Serial.println(yPosition);
  #endif
}

void setAngle(float angle) {
  theta = angle;
  // IMPORTANT: Setting isHeadingSet true allows botCheck to complete
  isThetaSet = true;
  #if DEBUG
  Serial.print(F("Theta set to: ")); Serial.println(theta);
  #endif
}

void setLeftMotor(int16_t value) {
  leftInput = value;
  #if DEBUG
  Serial.print(F("Left motor set to: ")); Serial.println(leftInput);
  #endif
}

void setRightMotor(int16_t value) {
  rightInput = value;
  #if DEBUG
  Serial.print(F("Right motor set to: ")); Serial.println(rightInput);
  #endif
}

void goFixed(unsigned long duration) {
  // Drive the motors
  driveArdumoto(MOTOR_L, leftInput);
  driveArdumoto(MOTOR_R, rightInput);
  // Calculate endtime
  endTime = millis() + duration;
  // Set to true to indicate it needs to be stopped in future
  isMovingFixed = true;
  #if DEBUG
  Serial.print(F("Moving for: ")); Serial.print(duration); Serial.println(F(" milliseconds"));
  #endif
}

void setPos(float x, float y, float angle) {
  xPosition = x;
  yPosition = y;
  theta = angle;
  #if DEBUG
  Serial.print(F("X Position set to: ")); Serial.println(xPosition);
  Serial.print(F("Y Position set to: ")); Serial.println(yPosition);
  Serial.print(F("Theta set to: ")); Serial.println(theta);
  #endif
}

/*
 * startRssi() initializes a new array of the required size
 */
void startRssi(uint8_t n) {
  // Set the number of beacons
  numBeacons = n;
  // Set the initial value
  rssiValues[0] = rx16.getRssi();
  // Reset/increment beacon
  beacon = 1;
}

void nextBeacon() {
  // Store next RSSI value
  rssiValues[beacon] = rx16.getRssi();
  beacon++;
  // Check if we've received all the pings
  if (beacon >= numBeacons) {
    // Allocate payload
    uint8_t payload[numBeacons+1];
    // First byte is instruction
    payload[0] = 0x09;
    // Copy the RSSI values
    for (int i = 0; i < numBeacons; i++)
      payload[i+1] = rssiValues[i];
    // Send the response with all the RSSI values
    sendTx16Request(payload, numBeacons+1);
  }
}
