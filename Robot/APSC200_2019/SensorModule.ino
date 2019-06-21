//configureSensor sets the tolerances/sensitivties of the sensors, other options can be uncommented to switch them
void configureSensor(void)
{
  // 1.) Set the accelerometer range
  lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_2G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_4G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_6G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_8G);
  //lsm.setupAccel(lsm.LSM9DS0_ACCELRANGE_16G);
  
  // 2.) Set the magnetometer sensitivity
  lsm.setupMag(lsm.LSM9DS0_MAGGAIN_2GAUSS);
  //lsm.setupMag(lsm.LSM9DS0_MAGGAIN_4GAUSS);
  //lsm.setupMag(lsm.LSM9DS0_MAGGAIN_8GAUSS);
  //lsm.setupMag(lsm.LSM9DS0_MAGGAIN_12GAUSS);

  // 3.) Setup the gyroscope
  lsm.setupGyro(lsm.LSM9DS0_GYROSCALE_245DPS);
  //lsm.setupGyro(lsm.LSM9DS0_GYROSCALE_500DPS);
  //lsm.setupGyro(lsm.LSM9DS0_GYROSCALE_2000DPS);
}

//displaySensorDetails gets the sensor details from the ui
void displaySensorDetails(void)
{  
  lsm.getSensor(&accelSetup, &magSetup, &gyroSetup, &tempSetup);
  #if DEBUG
  Serial.println(F("------------------------------------"));
  Serial.print  (F("Sensor:       ")); Serial.println(accelSetup.name);
  Serial.print  (F("Driver Ver:   ")); Serial.println(accelSetup.version);
  Serial.print  (F("Unique ID:    ")); Serial.println(accelSetup.sensor_id);
  Serial.print  (F("Max Value:    ")); Serial.print(accelSetup.max_value); Serial.println(F(" m/s^2"));
  Serial.print  (F("Min Value:    ")); Serial.print(accelSetup.min_value); Serial.println(F(" m/s^2"));
  Serial.print  (F("Resolution:   ")); Serial.print(accelSetup.resolution); Serial.println(F(" m/s^2"));  
  Serial.println(F("------------------------------------"));
  Serial.println(F(""));

  Serial.println(F("------------------------------------"));
  Serial.print  (F("Sensor:       ")); Serial.println(magSetup.name);
  Serial.print  (F("Driver Ver:   ")); Serial.println(magSetup.version);
  Serial.print  (F("Unique ID:    ")); Serial.println(magSetup.sensor_id);
  Serial.print  (F("Max Value:    ")); Serial.print(magSetup.max_value); Serial.println(F(" uT"));
  Serial.print  (F("Min Value:    ")); Serial.print(magSetup.min_value); Serial.println(F(" uT"));
  Serial.print  (F("Resolution:   ")); Serial.print(magSetup.resolution); Serial.println(F(" uT"));  
  Serial.println(F("------------------------------------"));
  Serial.println(F(""));

  Serial.println(F("------------------------------------"));
  Serial.print  (F("Sensor:       ")); Serial.println(gyroSetup.name);
  Serial.print  (F("Driver Ver:   ")); Serial.println(gyroSetup.version);
  Serial.print  (F("Unique ID:    ")); Serial.println(gyroSetup.sensor_id);
  Serial.print  (F("Max Value:    ")); Serial.print(gyroSetup.max_value); Serial.println(F(" rad/s"));
  Serial.print  (F("Min Value:    ")); Serial.print(gyroSetup.min_value); Serial.println(F(" rad/s"));
  Serial.print  (F("Resolution:   ")); Serial.print(gyroSetup.resolution); Serial.println(F(" rad/s"));  
  Serial.println(F("------------------------------------"));
  Serial.println(F(""));

  Serial.println(F("------------------------------------"));
  Serial.print  (F("Sensor:       ")); Serial.println(tempSetup.name);
  Serial.print  (F("Driver Ver:   ")); Serial.println(tempSetup.version);
  Serial.print  (F("Unique ID:    ")); Serial.println(tempSetup.sensor_id);
  Serial.print  (F("Max Value:    ")); Serial.print(tempSetup.max_value); Serial.println(F(" C"));
  Serial.print  (F("Min Value:    ")); Serial.print(tempSetup.min_value); Serial.println(F(" C"));
  Serial.print  (F("Resolution:   ")); Serial.print(tempSetup.resolution); Serial.println(F(" C"));  
  Serial.println(F("------------------------------------"));
  Serial.println(F(""));
  #endif
}

//getHeading gets a snapshot of all of the sensors on the module, then uses magnetic field to calculate theta
void getHeading(){
  // Get sensor snapshot
  lsm.getEvent(&accel, &mag, &gyro, &temp);
  // Shift the magnetometer data for calibration
  mag.magnetic.x = magXScale*mag.magnetic.x + magXOffset;
  mag.magnetic.y = magYScale*mag.magnetic.y + magYOffset;
  // Compute heading
  heading = atan2(mag.magnetic.y, mag.magnetic.x) + PI/2;
  if (heading < 0)
    heading += 2*PI;
  theta = heading - baseline;
  if (theta < 0)
    theta += 2*PI;

  #if DEBUG
  Serial.print("X: "); Serial.print(mag.magnetic.x, 5); Serial.print(" Y: "); Serial.println(mag.magnetic.y, 5);
  Serial.print("Heading: "); Serial.print(heading*180/PI); Serial.print(" Theta: "); Serial.println(theta*180/PI);
  Serial.print("Heading: "); Serial.print(heading); Serial.print(" Theta: "); Serial.println(theta);
  #endif
}

// calibrateMagnetometer sets the magX/magY offset and scale values
// The bot should spin around and take readings to detetermine the magnetic field strength in x and y
// then determine the max/min readings, and calculate the calibrate values based on their linear relationship
void calibrateMagnetometer() {
  // Set motors to move
  driveArdumoto(MOTOR_L, 128);
  driveArdumoto(MOTOR_R, -128);
  // Perform routine for 10 seconds (optimize?)
  unsigned long caliEndTime = millis() + 5000;
  // Loop
  while (millis() < caliEndTime) {
    getHeading();
    minX = minX > mag.magnetic.x ? mag.magnetic.x : minX;
    minY = minY > mag.magnetic.y ? mag.magnetic.y : minY;
    maxX = maxX < mag.magnetic.x ? mag.magnetic.x : maxX;
    maxY = maxY < mag.magnetic.y ? mag.magnetic.y : maxY;
  }
  // Stop motors
  driveArdumoto(MOTOR_L, 0);
  driveArdumoto(MOTOR_R, 0);
  // Calculate calibration values
  magXOffset = (maxX > 0 ? -1 : 1)*(maxX + minX)/2;
  magYOffset = (maxY > 0 ? -1 : 1)*(maxY + minY)/2;
  // Ranges are intermediate values used to determine which axis to apply scaling to
  float rangeX = maxX - minX, rangeY = maxY - minY;
  rangeX *= rangeX < 0 ? -1 : 1;
  rangeY *= rangeY < 0 ? -1 : 1;
  // One of these will be 1, the other > 1
  magXScale = max(rangeX, rangeY)/rangeX;
  magYScale = max(rangeX, rangeY)/rangeY;
  
  #if DEBUG
  Serial.print("maxX: "); Serial.print(maxX); Serial.print(" maxY: "); Serial.println(maxY);
  Serial.print("minX: "); Serial.print(minX); Serial.print(" minY: "); Serial.println(minY);
  Serial.print("rangeX: "); Serial.print(rangeX); Serial.print(" rangeY: "); Serial.println(rangeY);
  Serial.print("magXOffset: "); Serial.print(magXOffset); Serial.print(" magYOffset: "); Serial.println(magYOffset);
  Serial.print("magXScale: "); Serial.print(magXScale); Serial.print(" magYScale: "); Serial.println(magYScale);
  #endif
}

