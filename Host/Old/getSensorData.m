function [encoders, TOAD_flags, TOAD] = getSensorData(botsLower, XbeeSerial)
%Gets the encoder values, the time of arrival difference between the infared
%and the ultrasonic sensors and whether the data is new or not

encoders = zeros(length(botsLower), 2);
TOAD = zeros(length(botsLower), 5);

for i = 1:length(botsLower)
    while (true)
        disp("here 4");
        pause(0.02);
        write(XbeeSerial, botsLower(i));
        check = char(read(XbeeSerial, 1));
        if (check == botsLower(i))
            break;
        end
    end
    %Get all of the bytes for the 2 encoders (each are 2 byte/ 16 bit values)
    leftEncoderLow = read(XbeeSerial, 1, 'uint8');
    leftEncoderHigh = read(XbeeSerial, 1, 'uint8');    
    rightEncoderLow = read(XbeeSerial, 1, 'uint8');
    rightEncoderHigh = read(XbeeSerial, 1, 'uint8');
    %Get all of the bytes for the 5 beacon TOADs for the robot (each are 2
    %bytes)
    TOAD1Low = read(XbeeSerial, 1, 'uint8');
    TOAD1High = read(XbeeSerial, 1, 'uint8');
    TOAD2Low = read(XbeeSerial, 1, 'uint8');
    TOAD2High = read(XbeeSerial, 1, 'uint8');
    TOAD3Low = read(XbeeSerial, 1, 'uint8');
    TOAD3High = read(XbeeSerial, 1, 'uint8');
    TOAD4Low = read(XbeeSerial, 1, 'uint8');
    TOAD4High = read(XbeeSerial, 1, 'uint8');
    TOAD5Low = read(XbeeSerial, 1, 'uint8');
    TOAD5High = read(XbeeSerial, 1, 'uint8');
    
    %Get the byte (8 bit value) that store all of the "new data" flags from
    %the beacons of the robot, top 3 bits will be zero always since there
    %are only 5 beacons
    flagsInteger = read(XbeeSerial, 1, 'uint8');
    
    %Converts the unsigned integer into a row vector with 5 columns (for
    %each beacon)
    TOAD_flags = de2bi(flagsInteger,5);
    
    %Concatenates the low and high encoder bytes into an array then converts 
    %each array into 16 bit integer (signed)
    leftEncoder = [leftEncoderHigh leftEncoderLow];
    rightEncoder = [rightEncoderHigh rightEncoderLow];
    encoders(i, 1) = typecast(uint8(leftEncoder), 'int16');
    encoders(i, 2) = typecast(uint8(rightEncoder), 'int16');
    
    %Concatenates the low and high TOAD bytes into an array then converts 
    %each array into 16 bit integer (unsigned)
    TOAD1 = [TOAD1High TOAD1Low];
    TOAD2 = [TOAD2High TOAD2Low];
    TOAD3 = [TOAD3High TOAD3Low];
    TOAD4 = [TOAD4High TOAD4Low];
    TOAD5 = [TOAD5High TOAD5Low];
    TOAD(i, 1) = typecast(uint8(TOAD1), 'uint16');
    TOAD(i, 2) = typecast(uint8(TOAD2), 'uint16');
    TOAD(i, 3) = typecast(uint8(TOAD3), 'uint16');
    TOAD(i, 4) = typecast(uint8(TOAD4), 'uint16');
    TOAD(i, 5) = typecast(uint8(TOAD5), 'uint16');
end

end
