///////////////////////////////////   ACCELEROMETER CALIBRATION FUNCTIONS   ////////////////////////////////////
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

void displaySensorDetails(void)
{  
  lsm.getSensor(&accelSetup, &magSetup, &gyroSetup, &tempSetup);
  
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
}

void getHeading(){
   lsm.getEvent(&accel, &mag, &gyro, &temp); 
  /*
  Serial.print("Accel X: "); Serial.print(accel.acceleration.x, 5); Serial.print(" ");
  Serial.print("  \tY: "); Serial.print(accel.acceleration.y, 5);       Serial.print(" ");
  Serial.print("  \tZ: "); Serial.print(accel.acceleration.z, 5);     Serial.println("  \tm/s^2");

  // print out magnetometer data
  Serial.print("Magn. X: "); Serial.print(mag.magnetic.x, 5); Serial.print(" ");
  Serial.print("  \tY: "); Serial.print(mag.magnetic.y, 5);       Serial.print(" ");
  Serial.print("  \tZ: "); Serial.print(mag.magnetic.z, 5);     Serial.println("  \tgauss");
  
  // print out gyroscopic data
  Serial.print("Gyro  X: "); Serial.print(gyro.gyro.x, 5); Serial.print(" ");
  Serial.print("  \tY: "); Serial.print(gyro.gyro.y, 5);       Serial.print(" ");
  Serial.print("  \tZ: "); Serial.print(gyro.gyro.z, 5);     Serial.println("  \tdps");
  */
  Serial.println("Here 1.5");
  
  heading = atan2(mag.magnetic.y, mag.magnetic.x);
  while(abs(heading) > 180){
    Serial.println(heading);
    if(heading > 180){
      heading = heading - 360;
    }
    else{
      heading = heading + 360;
    }
    Serial.println("Here 1.75");
  }
  Serial.print("Heading: "); Serial.print(heading, 5); Serial.println(" * from N?");
  theta = heading - baseline;
}

/*
void calibration(){ // open source gyroscope calibration function
  gz_offset=-mean_gz/4;
  while (1){
    ready=0;
    accelgyro.setZGyroOffset(gz_offset);
    meansensors();
    Serial.println("...");
    if (abs(mean_gz)<=giro_deadzone) ready = 1;
    else gz_offset=gz_offset-mean_gz/(giro_deadzone+1);
    if (ready==1) break;
  }
}
void meansensors(){ // open source function used in gyroscope calibration
  long i=0,buff_gz=0;
  while (i<(buffersize+101)){
    gyroZ = accelgyro.getRotationZ(); // read raw accel/gyro measurements from device
    if (i>100 && i<=(buffersize+100)){ //First 100 measures are discarded
      buff_gz=buff_gz+gyroZ;
    }
    if (i==(buffersize+100)){
      mean_gz=buff_gz/buffersize;
    }
    i++;
    delay(2); //Needed so we don't get repeated measures
  }
}
void Calibration_main() { // open source gyroscope calibration function
    meansensors();
    delay(1000);
    calibration();
    delay(1000);
    meansensors();
}
void thetaCalculation(){
    currentTime = millis();
    gyroZ = (float) accelgyro.getRotationZ()/131;
    if(abs(gyroZ) > 0.2){
      theta = theta + gyroZ*(PI/180)*(currentTime-oldTime)/1000; 
    }
    while(true){  
      if (theta > PI){ 
        theta = theta - 2*PI;
      }else if(theta < -PI){
        theta = theta + 2*PI;
      }else{
        break;
      }
    }
    oldTime = currentTime;
}
*/

