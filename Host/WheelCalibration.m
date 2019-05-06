% Calibrates wheels
function [leftInputSlope, leftInputIntercept, rightInputSlope, rightInputIntercept] = WheelCalibration(XbeeSerial, tag, lowerTag)
%Clear the workspace to start the program 
% close all
% clear
% clc
% 
% %Setup the raspberry pi connection, as well as a connection to the Xbee on
% %the RPi
% rpi = raspi('130.15.101.192','pi','swep2017');
% XbeeSerial = serialdev(rpi,'/dev/ttyUSB0',9600); %define the serial port and set the BAUD rate
% 
% %Call the Setup function with the Xbee object to set up all robots, it will
% %take user input for all robot tags for robots in use
% [tag, lowerTag] = Setup(XbeeSerial);

%% Left Wheel
tic;

leftInput = 255;
rightInput = 0;

% Send speeds to motor
ManualWheelSet(XbeeSerial, tag, leftInput, rightInput);
pause(2);
% get encoder ticks
Ticks = getSensorsXbee(lowerTag, XbeeSerial);
leftTicks = Ticks(1);
leftRotation = leftTicks*2*pi/192;
endTime = toc;
leftSpeedMax = leftRotation/endTime;


leftInput = 100;
rightInput = 0;

gotIt = 0; %these will keep track of our process in a bit
goingDown = 0;

oldTicks = 0;
while (true)
    tic;

% Send speeds to motor
ManualWheelSet(XbeeSerial, tag, leftInput, rightInput);
pause(2);
% get encoder ticks
Ticks = getSensorsXbee(lowerTag, XbeeSerial);
leftTicks = Ticks(1);
leftRotation = (leftTicks-oldTicks)*2*pi/192;
oldTicks = leftTicks;
endTime = toc;


    %%% Calculate speed
    leftSpeed = leftRotation/endTime;
    
    if abs(leftSpeed) < 0.01 %account for some error in # of ticks counted (this is about the speed of what 1 speed level over zero should give)
        gotIt = 1; %to keep track of the fact we've already mapped to zero
        if goingDown == 1 %if we're coming from a higher input that didn't work, then we've already found our best input
            break;
        end 
        leftInput = leftInput + 5; %see if higher values will still map to zero
    else %in this case, the robot moved, so we want to decrease the inputs
        if gotIt == 1 %if we've already mapped to zero, and we're not anymore, we want to break
            leftInput = leftInput - 5; %this would be when we satisfied the zero condition
            break;
        end 
        leftInput = leftInput - 5;
        goingDown = 1;
    end 
    
end 

leftInputIntercept = leftInput;
leftInputSlope = (255-leftInputIntercept)/leftSpeedMax;


%% Right Wheel

tic;

leftInput = 0;
rightInput = 255;

% Send speeds to motor
ManualWheelSet(XbeeSerial, tag, leftInput, rightInput);
pause(2);
% get encoder ticks
Ticks = getSensorsXbee(lowerTag, XbeeSerial);
rightTicks = Ticks(2);
rightRotation = rightTicks*2*pi/192;
endTime = toc;

%%% Calculate speed
rightSpeedMax = rightRotation/endTime;

gotIt = 0;
goingDown = 0;

% Prepare to find zeros with most common zero input
leftInput = 0;
rightInput = 100;
sensors = getSensorsXbee(lowerTag, XbeeSerial);
oldTicks = sensors(2);
while (true)
    tic;
         
    % Send speeds to motor
    ManualWheelSet(XbeeSerial, tag, leftInput, rightInput);
    pause(2);
    
    % get encoder ticks
    Ticks = getSensorsXbee(lowerTag, XbeeSerial);
    rightTicks = Ticks(2);
    rightRotation = (rightTicks-oldTicks)*2*pi/192;
    oldTicks = rightTicks;
    endTime = toc;

    %%% Calculate speed
    rightSpeed = rightRotation/endTime;
    
    if abs(rightSpeed) < 0.01 %account for some error in # of ticks counted
        gotIt = 1; %to keep track of the fact we've already mapped to zero
        if goingDown == 1 %if we're coming from a higher input that didn't work, then we've already found our best input
            break
        end 
        rightInput = rightInput + 5; %see if higher values will still map to zero
    else %in this case, the robot moved, so we want to decrease the inputs
        if gotIt == 1 %if we've already mapped to zero, and we're not anymore, break
            rightInput = rightInput - 5; %this would be when we satisfied the zero condition
            break;
        end 
        rightInput = rightInput - 5;
        goingDown = 1; %our inputs are decreasing, so we don't want to increase if we hit the right one
    end 
end 

rightInputIntercept = rightInput;
rightInputSlope = (255-rightInput)/rightSpeedMax;

fopen(XbeeSerial);
fwrite(XbeeSerial, lowerTag);
fwrite(XbeeSerial, lowerTag);
fwrite(XbeeSerial, lowerTag);
fclose(XbeeSerial);
end 
