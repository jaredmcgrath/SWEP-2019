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
positiontwo = position;

for i = 1:length(bots)
    position(i,:) = input(['Input the x and y  and theta coordinates of bot ' bots(i) ', seperate the two coordinates with a space.']);
end

nextPosition = zeros(length(bots), 3);
sensors = getSensors(botsLower, XbeeSerial);
newSensors = sensors

%For storing and timing 
j = 1;
tic;

    %ask the user to input the next position they want all of the robots to go to  
    for i = 1:length(bots)
        nextPosition(i,:) = input(['Input the x and y coordinates you''d like ' bots(i) ' to go to, seperate the two coordinates with a space.']);
    end
    
    %%%%%CONTROL SECTION%%%%%
    %see if each robot is at its next position, 

        AdjustPosition(XbeeSerial, bots, position, nextPosition);
        newSensors = getSensors(botsLower, XbeeSerial)
        
        %for plotting the sensor values as a function of time
        for i = 1:length(bots)
            store(i, j, 3) = toc;
            store (i, j, 1:2) = newSensors(i,:);
        end
        j = j + 1;
        
        %Calculate radians of the encoders from the ticks
        leftTicks = (newSensors(:,1) - sensors(:,1))*2*pi/192; %in radians 
        rightTicks = (newSensors(:,2) - sensors(:,2))*2*pi/192;
        
        %determine the angle of the robot
        position(:,3) = position(:,3) + 1/2*0.063/2*(1/(0.126/2))*(rightTicks - leftTicks);
        
        %make sure that the angle is in the -pi to pi range
        while(abs(position(:, 3)) >= pi)
            if (position(:, 3) > 0)
                position(:, 3) = position(:, 3) - 2*pi;
            else
                position(:, 3) = position(:, 3) + 2*pi;
            end
        end
        
        %Use localisation
        for i = 1:length(bots)
            position(i,1) = position(i,1) + cos(position(i,3)).*0.065.*0.5.*0.5.*(leftTicks(i) + rightTicks(i));
            position(i,2) = position(i,2) + sin(position(i,3)).*0.065.*0.5.*0.5.*(leftTicks(i) + rightTicks(i));
        end
        
        sensors = newSensors;
        
        pause(1);
        
        AdjustPosition(XbeeSerial, bots, nextPosition, nextPosition);
        newSensors = getSensors(botsLower, XbeeSerial)
        
        %Calculate radians of the encoders from the ticks
        leftTicks = (newSensors(:,1) - sensors(:,1))*2*pi/192; %in radians 
        rightTicks = (newSensors(:,2) - sensors(:,2))*2*pi/192;
        
        %determine the angle of the robot
        positiontwo(:,3) = positiontwo(:,3) + 1/2*0.063/2*(1/(0.126/2))*(rightTicks - leftTicks);
        
        %make sure that the angle is in the -pi to pi range
        while(abs(positiontwo(:, 3)) >= pi)
            if (positiontwo(:, 3) > 0)
                positiontwo(:, 3) = positiontwo(:, 3) - 2*pi;
            else
                positiontwo(:, 3) = positiontwo(:, 3) + 2*pi;
            end
        end
        
        %Use localisation
        for i = 1:length(bots)
            positiontwo(i,1) = position(i,1) + cos(positiontwo(i,3)).*0.065.*0.5.*0.5.*(leftTicks(i) + rightTicks(i));
            positiontwo(i,2) = position(i,2) + sin(positiontwo(i,3)).*0.065.*0.5.*0.5.*(leftTicks(i) + rightTicks(i));
        end