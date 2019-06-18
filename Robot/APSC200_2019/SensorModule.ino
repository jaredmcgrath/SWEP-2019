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

  // Get sensor info for the old sensor data
  lsm.getEvent(&accel, &mag, &gyro, &temp);
  // Perform deep copy on magnetometer's x,y,z
  gravity.x = mag.magentic.x;
  gravity.y = mag.magentic.y;
  gravity.z = mag.magentic.z;
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
  // Low-pass filter on accelerometer data to (hopefully) yield gravity
  lpf(&(accel.acceleration), &gravity, 0.95);
  // Normalize gravity, mag
  norm(&gravity, &gravNorm);
  norm(&(mag.magnetic), &magNorm);
  // Cross magnetic field with gravity to yield the eastern direction
  cross(&gravNorm, &magNorm, &east);
  // Cross east with gravity to yield north
  cross(&gravNorm, &east, &north);
  // Compute heading from north vector
  heading = atan2(north.y, north.x);
  theta = heading - baseline;

  #if DEBUG
  Serial.print("Mag X: "); Serial.println(north->x);
  Serial.print("Mag Y: "); Serial.println(north->y);
  #endif
}

// lpf is a low pass filter. The resultant is located at rslt, which is a pointer to a sensors_vec_t struct
void lpf(sensors_vec_t *eventData, sensors_vec_t *rslt, float bias) {
  rslt->x = rslt->x * bias + eventData->x * (1 - bias);
  rslt->y = rslt->y * bias + eventData->y * (1 - bias);
  rslt->z = rslt->z * bias + eventData->z * (1 - bias);
}

// Computes cross product a X b, stores resultant in rslt
void cross(sensors_vec_t *a, sensors_vec_t *b, sensors_vec_t *rslt) {
  rslt->x = a->y * b->z - a->z * b->y;
  rslt->y = a->z * b->x - a->x * b->z;
  rslt->z = a->x * b->y - a->y * b->x;
}

// Computes the norm of a vector AND normalizes it, storing result in rslt
void norm(sensors_vec_t *v, sensors_vec_t *rslt) {
  float norm = sqrt(sq(v->x) + sq(v->y) + sq(v->z));
  rslt->x = v->x/norm;
  rslt->y = v->y/norm;
  rslt->z = v->z/norm;
}
