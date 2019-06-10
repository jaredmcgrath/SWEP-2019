function [sensors] = getSensors(botsLower, XbeeSerial)
%Gets the initial sensor values of each robot, assuming that there are 3
%sensors (2 encoders, one gyro angle)

sensors = zeros(length(botsLower), 2);
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
    byte1 = read(XbeeSerial, 1, 'uint8');
    byte2 = read(XbeeSerial, 1, 'uint8');
    sensor1 = [byte2 byte1];
    sensors(i, 1) = typecast(uint8(sensor1), 'int16');
    byte3 = read(XbeeSerial, 1, 'uint8');
    byte4 = read(XbeeSerial, 1, 'uint8');
    sensor2 = [byte4 byte3];
    sensors(i, 2) = typecast(uint8(sensor2), 'int16');

    %sensors(i, 3) = read(XbeeSerial, 1);
end

end
