%% APSC 200: Main Robot Script
% This is the main program for running the robots in the desired group
% dynamics. This script is brokendown into several functions that are 
% detailed below. The user defined external functions (to two levels) that
% are called in each section of the code required to run the overall script
% are also described below. 

%   - Runtime Parameters
%   - Xbee Setup
%   - Robot Setup
%       -> initializeBotState.m
%       -> sendInitialState.m
%           => sendInstruction.m
%   - Wheel Calibration
%       -> calibrateWheels.m
%           => sendInstruction.m
%   - Main Loop Variable Declaration
%       -> PositionCalc.m
%           => pingBeacon.m
%           => getAllDataXbee.m
%           => getSensorsXbee.m
%           => filterBeaconData.m
%           => EKF.m
%       -> getNextPosition.m
%           => Flocking.m
%           => Formation.m
%           => Krause.m
%           => Deployment.m
%   - Main Loop
%       -> checkPosition.m
%       -> getNextPosition.m
%           => Flocking.m
%           => Formation.m
%           => Krause.m
%           => Deployment.m
%       -> AdjustPosition.m
%       -> PositionCalc.m
%           => pingBeacon.m
%           => getAllDataXbee.m
%           => getSensorsXbee.m
%           => filterBeaconData.m
%           => EKF.m

%Clear the workspace to start the program 
close all
clear
clc

%% TO DO
% - Make a config file for all settings instead of hard-coding them

%% RUNTIME PARAMETERS

% Variables in code that are affected by variables in the Arduino code
%   - time_step ->(in EKF) should be the same as movementDuration in the
%           Arduino code 
%   - pingBeaconDelay -> dependent on BEACON_TIMEOUT_THRESHOLD in the 
%           Arduino code

% Recompiles pingBeacon.c on the RPi once during setup. Do this if you have
% made changes to pingBeacon.c
recompilePingBeaconCode = false;
enableDebuggingRPi = false; 
% Enable debugging for this script and related functions
debug = true;

% The config file name
configFileName = 'config.xml';
% Read config file into a struct
config = parseConfig(configFileName);
% Filename of the .mat containing the path
pathFileName = 'agentData.mat';
% END RUNTIME PARAMETERS

%% OLD LOCALIZATION SETUP 
% (remove or revise, not functional)
%rpi = raspi('130.15.101.192','pi','swep2018');      % New RPi 3
%rpi = raspi('130.15.101.119','pi','apsc200');      % Old RPi 1
% Where the relevant files for firing the beacons are stored on the RPi
%pingBeaconPath = '/home/pi/Desktop/apsc200devRPi';
% IR and US GPIO pins on the RPi for each beacon. 
% For beacon #i, beaconGPIO(i) = [IR_PIN_i, US_PIN_i];
%beaconGPIO = [17, 27; 
%               10,  9;
%               19, 26;
%               25,  8; 
%               20, 21];     


% EKF setup
% Beacon information
% beaconLocations = [1.5,0; 0.5,0; 0,0.5; 1.5,0; 2.5,0];   % [x1,y1;x2,y2,...]
% Initial error covariance matrix
% errorCovMat = 1*eye(3,3);   % [3x3] since the state is of dimension 3 

% localizeThisIteration = true;
% pingBeaconDelay = 1.5; 
% % Recompile the pingBeacon.c code on the RPi if necessary
% if (recompilePingBeaconCode)
%     pingBeaconRecompile(pingBeaconPath, enableDebuggingRPi);
% end
% END OLD LOCALIZATION SETUP

%% XBEE SETUP
% Set up the Xbee connection
config.xbee = serial('COM8','Terminator','CR', 'Timeout', 1);

% END XBEE SETUP

%% BOT SETUP
% Call the initializeBotState to get list of bots being worked with, and
% their states
[position, tags, xHeading] = initializeBotState(config);
% Send initial positions to bots
sendInitialState(config, position, tags, xHeading);
disp('Bots setup successfully')

% END BOT SETUP

%% PATH LOADING
% Loads the paths for the agents
pathFile = load(pathFileName);
% Take all history, truncate columns to match number of robots
path = pathFile.agentPositionHistory(:,1:2*length(tags));

% END PATH LOADING

%% WHEEL CALIBRATION
% See if the user wants to calibrate the robots wheels
% If not, the values from config will be used
if strcmpi(input('Calibrate bots? (y/n) ', 's'), 'y')
    [slope, intercept] = calibrateWheels(config,tags);
    % Update config file to the new values
    saveWheelConfig(configFileName, slope, intercept, tags);
else
    slope = config.slope(ismember(config.validTags,tags),:);
    intercept = config.intercept(ismember(config.validTags,tags),:);
end

% END WHEEL CALIBRATION

%% CREATE SENSOR AND POSITION VARIABLES FOR EACH ROBOT
%{
% Algorithm Selection
% Display possible options for users to pick from. User selects one of the
% options. Option selected is saved to the algorithm variable
load('algorithmOptions.mat')
disp('Formation Options')
for i = 1:size(algorithmOptions,2)
    disp(cell2mat(algorithmOptions(i)));
end
algorithm = input('Enter Number for Corresponding Formation Type: ');

% Allows user to enter parameters unique to each algorithm
algorithmParameters = algorithmSettings(algorithm, tags);
%}

%% MAIN LOOP
% High-level overview of what should happen (tentatively)
% - Get current robot positions
% - Compare current positions to where they should be
% - Apply control to put them on track

% pathIndex keeps track of where we are in the path
pathIndex = 1;
while pathIndex <= size(path,1)
    [position, heading] = getPositions(config, tags);
    [desiredPosition, pathIndex] = getDesiredPositions(config, position,...
        path, pathIndex);
    controlInput = getControlInputs(config, position, heading,...
        desiredPosition, slope, intercept);
    sendControlInputs(config, tags, controlInput);
    %pause(0.15);
end

%% OLD MAIN LOOP
% %% Create Sensor and Position variables for each robot
% position = zeros(length(bots), 3);
% oldPosition = position;
% % Estimate/predict next position (depending on if we localize or not)
% [position, errorCovMat] = PositionCalc(botTagLower, beaconLocations,...
%     errorCovMat, xbeeSerial, rpi, localizeThisIteration, beaconGPIO,...
%     pingBeaconPath, pingBeaconDelay, debug, oldPosition);
% 
% nextPosition = getNextPosition(algorithm, bots, position);
% error = zeros(3*length(bots),1);
% 
% 
% exitCounter = 0;
% index = 1;
% 
% %% Main loop
% while (true) 
%     localizeThisIteration = true;
%     %see if any of the robots are its next position
%     for i= 1:length(bots)
%         check = checkPosition(position(i,:),nextPosition(i,:));
%         if(check == true)
%             nextPosition = getNextPosition(algorithm, bots, position);
%         end
%         %check to see if the robot's new position is its current position
%         check = checkPosition(position(i,:),nextPosition(i,:));
%         if(check == true)
%             exitCounter = exitCounter + 1;
%         end
%     end
%     
%     %if all of the new positions match the robots' old position, exit the
%     %program
%     if(exitCounter == length(bots))
%         break;
%     end
% 
%     %%%%%CONTROL SECTION%%%%%
%     % Determine motor inputs based off of controller 
%   
%     AdjustPosition(xbeeSerial, bots, position, ...
%         nextPosition, index, error, leftInputSlope, leftInputIntercept, ...
%         rightInputSlope, rightInputIntercept);
% 
% 
%     % start all the robots to start moving after giving them motor inputs
%     fopen(xbeeSerial);
%     fwrite(xbeeSerial, '1');
%     fclose(xbeeSerial);
% 
%     %%%%%NAVIGATION AND ESTIMATION SECTION%%%%%        
%     % calculate the new position of the robot
%     oldPosition = position;
%     [position, errorCovMat] = PositionCalc(botTagLower, beaconLocations, ...
%         errorCovMat, xbeeSerial, rpi, localizeThisIteration, beaconGPIO, ...
%         pingBeaconPath, pingBeaconDelay, debug, oldPosition);
%     
%     index = index + 1;
% 
% end
% 
% disp("All robots should be optimally arranged.");
