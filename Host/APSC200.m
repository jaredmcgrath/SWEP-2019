%% APSC 200: Main Robot Script
% This is the main program for running the robots in the desired group
% dynamics. Current implementation does not perform any localization, and
% LQR controller is implemented on the host

%Clear the workspace to start the program 
close all
clear
clc

%% RUNTIME PARAMETERS

% The config file name
configFileName = 'config.xml';
% Read config file into a struct
config = parseConfig(configFileName);
% Filename of the .mat containing the path
pathFileName = 'agentData.mat';

% Add XBee class definition folder to path
addpath('XBee');
% END RUNTIME PARAMETERS

%% BOT SETUP
% Call the initializeBotState to get list of bots being worked with, and
% their states
[position, tags, theta] = initializeBotState(config);
% Send initial positions to bots
sendInitialState(config.beacons(1), position, tags, theta);
disp('Bots setup successfully');
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

%% MAIN LOOP
% High-level overview of what should happen
% - Get current robot positions (getPositions)
% - Compare current positions to where they should be (getDesiredPositions)
% - Determine control inputs to navigate (getControlInputs)
% - Move the robots (sendControlInputs)

% pathIndex keeps track of where we are in the path
pathIndex = 1;
while pathIndex <= size(path,1)
    [position, heading] = getPositions(config, tags);
    [desiredPosition, pathIndex] = getDesiredPositions(config, position,...
        path, pathIndex);
    controlInput = getControlInputs(config, position, heading,...
        desiredPosition, slope, intercept);
    sendControlInputs(config, tags, controlInput);
end
