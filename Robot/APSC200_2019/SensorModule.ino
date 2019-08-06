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
  #if DEBUG > 0
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

void calcGyroAngle()
{
  // This function calculates the heading of the robot using the gyro sensor on the LSM9DS0 sensor module
  // The first step is to obtain the gain reading from the gyro sensor for the z-axis and record the time 
  // from program start that the reading was taken
  lsm.getEvent(&accel, &mag, &gyro, &temp);
  gyroGain = gyro.gyro.z;
  gyroTime = float(millis());

  // Calculate the raw gyro angle [in degrees] to keep track of the drift the sensor experiences over time
  gyroAngleRaw = gyroAngleRaw + (float)((gyroTime - gyroTimePrevious)/1000)*gyroGain;
  
  // Calcualte the corrected gyro angle [radians] using the previous raw angle measurement (which is in degrees) 
  gyroAngleCorrected = (gyroAngleRaw - (GYRO_CORRECTION_SLOPE * gyroTime - GYRO_CORRECTION_INTERCEPT))*PI/180;
  
  // Set of conditionals to keep the corrected heading angle within 0 to 2*PI.
  if (gyroAngleCorrected > 2*PI)
  {
    gyroAngleCorrected = gyroAngleCorrected - 2*PI;
  }
  else if (gyroAngleCorrected < 0)
  {
    gyroAngleCorrected = gyroAngleCorrected + 2*PI;
  }
  // Stores the time of the current measurement in a variable to be called for in the next iteration of the function
  gyroTimePrevious = gyroTime;

  #if DEBUG > 0
  Serial.print(gyroTime);
  Serial.print(",");
  Serial.print(gyroGain);
  Serial.print(",");
  Serial.println(gyroAngleCorrected);
  #endif
}
