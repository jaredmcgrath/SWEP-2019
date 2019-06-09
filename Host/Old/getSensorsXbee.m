function [sensors] = getSensorsXbee(botsLower, XbeeSerial)
%Gets the x, y, and theta estimations from the robot
% while (true)
%     disp("getSensors");
%     pause(0.02);
%     fwrite(XbeeSerial, botsLower(i));
%     check = char(fread(XbeeSerial, 1));
%     if (check == botsLower(i))
%         break;
%     end
% end
%opens the serial port to talk to the Xbee
fopen(XbeeSerial);

%sets up the variable for the data to be stored
sensors = zeros(length(botsLower), 3);

%iterates through all of the robots to get their data
for i = 1:length(botsLower)
    %writes their lowercase bot tag to the robots until they respond with 
    %their tag
    while (true)
        disp("getSensors");
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

end

%closes the serial port, good practice
fclose(XbeeSerial);
end
