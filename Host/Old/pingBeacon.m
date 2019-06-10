function pingBeacon(rpi, beaconGPIO, beaconID, pingBeaconPath)

% Contains GPIO pins for IR and US transmission for each beacon. 
% Usage: For beacon #i, beaconGPIO(i) = [IR_PIN_i, US_PIN_i];
% rpi must be in the following form: 
% rpi = raspi('<ip address>','<username>','<password>');


irPin = int2str(beaconGPIO(beaconID,1));
usPin = int2str(beaconGPIO(beaconID,2));

value = system(rpi,strcat('cd',32,pingBeaconPath,';',32,'sudo ./pingBeacon',...
    32,irPin,32,usPin,32,int2str(beaconID)));
            
if not(value)
    error("pingBeacon failed. Command returned:"); 
    disp(value);
end
            
            
end

                
            
            


