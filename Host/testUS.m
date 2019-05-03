function testUS(rpi, path, pin)
%tests a pin on the raspberry pi to see that its working properly
    %values for the rpi
    %rpi = raspi('130.15.101.192','pi','swep2018'); 
    %path = '/home/pi/Desktop/apsc200devRPi';
    
    testPin = int2str(pin);
    
    value = system(rpi,strcat('cd',32,path,';',32,'sudo ./testUS',...
        32,testPin));

    if not(value)
        error("pingBeacon failed. Command returned:");
        disp(value);
    end
end