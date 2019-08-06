%% APSC 200: Main Robot Script
% This is the main program for running the robots in the desired group
% dynamics. This script is designed to work with the robots performing PID
% control. 
% Key differences: 
% - Localization is to happen when a bot reaches a target point
% - Each bot is able to request its next target point
% - The host program serves as the hub to coordinate localization, and to
%   ensure bots are syncronized
%    - Host program synchronizes by waiting for all bots to request their
%    next target point before sending the next target points
% - This script does NOT do any calibration of the bots' wheels. This is
%   only needed for the LQR controller

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

% Leave the main XBee port open
fopen(config.beacons(1));
% END RUNTIME PARAMETERS

%% BOT SETUP
% Call the initializeBotState to get list of bots being worked with, and
% their states
[position, tags, theta] = initializeBotState(config);
% Send initial positions to bots
request = sendInitialState(config, position, tags, theta);
disp('Bots setup successfully');
% END BOT SETUP

%% PATH LOADING
% Loads the paths for the agents
pathFile = load(pathFileName);
% Take all history, truncate columns to match number of robots
path = pathFile.agentPositionHistory(:,1:2*length(tags));
% END PATH LOADING

%% MAIN LOOP
% High-level overview of what should happen
% - Parse any packets received and respond appropriately
% - If the program is done navigating, tell bots to stop
% - While all of this is happening, need to alays check for simultaneous
%   requests from robots, store them, and deal with them appropriately

% TODO: Debug this and figure out why nothing happens

% pathIndex keeps track of where we are in the navigation path
pathIndex = 1;
% nextPosTags keeps track of bots who have requested the next point
nextPosTags = '';
while pathIndex <= size(path,1)
    if config.beacons(1).BytesAvailable > 0
        % Parse any requests from bots
        request = [request parse(config.beacons(1))];
    end
    if ~isempty(request)
        % If we have any requests, handle them
        [posTags, request] = handleRequest(config, request);
        nextPosTags = strcat(nextPosTags, posTags);
    end
    % If all bots have requested next point, send them
    if all(ismember(tags, nextPosTags))
        for i=1:length(tags)
            [~, overlap] = sendInstruction(config, 'GET_NEXT', tags(i), ...
                path(pathIndex, 2*i-1:2*i));
            request = [request overlap];
        end
        pathIndex = pathIndex + 1;
    end
end
sendInstruction(config, 'G_STOP');