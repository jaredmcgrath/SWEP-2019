function [sensors,errorCodes,distances] = getAllDataXbee(botsLower, XbeeSerial)
%Retrieves all of the localization data from the robot: x, y, theta
%estimations as well as the beacon distances and error codes

%open the serial port to communicate to the Xbee
fopen(XbeeSerial);

%Set up variables to save the data from the robot
sensors = zeros(length(botsLower), 3);
distances = zeros(length(botsLower), 5);
errorCodes = zeros(length(botsLower), 5);

%iterates through all of the robots to get their data
for i = 1:length(botsLower)
    %writes the character P to the robots until they respond with their tag
    %-- probably need to adjust to specific bots when multiple are being
    %used
    while (true)
        disp("get all data");
        pause(0.02);
        fwrite(XbeeSerial, botsLower(i));
        check = char(fread(XbeeSerial, 1));
        if (check == botsLower(i))
            break;
        end
    end

    sensors(i, 1) = fread(XbeeSerial, 1, 'single');
    sensors(i, 2) = fread(XbeeSerial, 1, 'single');
    sensors(i, 3) = fread(XbeeSerial, 1, 'single');
    
    distances(i, 1) = fread(XbeeSerial, 1, 'int16');
    distances(i, 2) = fread(XbeeSerial, 1, 'int16');
    distances(i, 3) = fread(XbeeSerial, 1, 'int16');
    distances(i, 4) = fread(XbeeSerial, 1, 'int16');
    distances(i, 5) = fread(XbeeSerial, 1, 'int16');
    
    errorCodes(i, 1) = fread(XbeeSerial, 1, 'uint8');
    errorCodes(i, 2) = fread(XbeeSerial, 1, 'uint8');
    errorCodes(i, 3) = fread(XbeeSerial, 1, 'uint8');
    errorCodes(i, 4) = fread(XbeeSerial, 1, 'uint8');
    errorCodes(i, 5) = fread(XbeeSerial, 1, 'uint8');

end

%close the serial port, good practice
fclose(XbeeSerial);
end
