%Clear the workspace to start the program 
close all
clear
clc

%Setup the raspberry pi connection, as well as a connection to the Xbee on
%the RPi
rpi = raspi('130.15.101.192','pi','swep2017');
XbeeSerial = serialdev(rpi,'/dev/ttyUSB0',9600); %define the serial port and set the BAUD rate

%Call the Setup function with the Xbee object to set up all robots, it will
%take user input for all robot tags for robots in use
[bots, botsLower] = Setup(XbeeSerial);

%ask the user to input the initial positions of all of the robots 
position = zeros(length(bots), 3);
for i = 1:length(bots)
    position(i,:) = input(['Input the x and y  and theta coordinates of bot ' bots(i) ', seperate the two coordinates with a space.']);
end

calibrate = input('Would you like to calibrate the wheels? Y or N', 's');
if (calibrate == 'Y' || calibrate == 'y')
    [leftInputSlope, leftInputIntercept, rightInputSlope, rightInputIntercept] = WheelCalibration(XbeeSerial, rpi, bots, botsLower);
else
    leftInputSlope = 13;
    leftInputIntercept = 90;
    rightInputSlope = 13;
    rightInputIntercept = 90;
end

nextPosition = zeros(length(bots), 3);

sensors = zeros(length(bots), 2);
newSensors = zeros(length(bots), 2); 

error = zeros(3,100);

path = [0 1;  0.5274 0.8496; 0.8962 0.4437; 0.9954 -0.0957; 0.7952 -0.6063; 0.3558 -0.9345; -0.1906 -0.9817; -0.6797 -0.7335; -0.9643 -0.2647; -0.9589 0.2837];

%For storing and timing 
j = 1;
k = 1;
tic;

    %ask the user to input the next position they want all of the robots to go to  
%     for i = 1:length(bots)
%         nextPosition(i,:) = input(['Input the x and y coordinates you''d like ' bots(i) ' to go to, seperate the two coordinates with a space.']);
%     end
    
    %%%%%CONTROL SECTION%%%%%
    %see if each robot is at its next position, 

while (true)
    if(checkPosition(position, nextPosition))
        nextPosition = path(k,:);
        k = k + 1;
        if (k == 11)
            break;
        end
    end
    
    startTime = toc;
    
    error(:,j+1) = AdjustPosition(XbeeSerial, bots, position, nextPosition, j, error, leftInputSlope, leftInputIntercept, rightInputSlope, rightInputIntercept);
    newSensors = getSensors(botsLower, XbeeSerial)

    

    %for plotting the sensor values as a function of time
    for i = 1:length(bots)
        store(i, j, 3) = toc;
        store (i, j, 1:2) = newSensors(i,:);
    end
    j = j + 1

    %Calculate radians of the encoders from the ticks
    leftTicks = (newSensors(:,1) - sensors(:,1))*2*pi/192; %in radians 
    rightTicks = (newSensors(:,2) - sensors(:,2))*2*pi/192;

    endTime = toc;

    leftSpeed = leftTicks/(endTime - startTime); %in radians per second
    rightSpeed = rightTicks/(endTime - startTime);

    %determine the angle of the robot
    position(:,3) = position(:,3) + 1/2*0.065/2*(1/(0.126/2))*(rightSpeed - leftSpeed);

    %Use localisation
    for i = 1:length(bots)
        position(i,1) = position(i,1) + cos(position(i,3)).*0.065.*0.5.*0.5.*(leftTicks(i) + rightTicks(i));
        position(i,2) = position(i,2) + sin(position(i,3)).*0.065.*0.5.*0.5.*(leftTicks(i) + rightTicks(i));
    end

    sensors = newSensors;


%         for i = 1:length(bots)
%             figure(i)
%             plot(store(i,:,3),store(i,:,1:2));
%         end
end



