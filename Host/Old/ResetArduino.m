function [] = ResetArduino(initXbee, XbeeSerial)
%Reset the Arduino, it restarts the program
if(initXbee)
    XbeeSerial = serial('COM7','Terminator','CR', 'Timeout', 2);
end

fopen(XbeeSerial);
fwrite(XbeeSerial, "R");
fclose(XbeeSerial);
end

