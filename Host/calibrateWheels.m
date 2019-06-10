function [slope, intercept] = calibrateWheels(xbeeSerial,tagIdStruct,...
    insStruct, tags)
%% calibrateWheels
% Calibrate robots by determining the slopes and intercepts from encoder
% ticks
%
% Parameters:
%   xbeeSerial
%     Serial port object for the XBee. The serial port should be closed
%     upon calling sendInitialState
%   tagIdStruct
%     A struct containing the numerical ID of each bot corresponding to
%     their character tag
%   insStruct
%     A struct containing the numerical value of each instruction
%     corresponding to the string value
%   tags
%     Character vector of the bots' tags that are being used. Should only
%     contain characters that are found in the bot tag list in the config
%     file. Each character represents one bot
%
% Returns:
%   slope
%     n-by-2 matrix of slopes in [left right; left right; ... ] format,
%     where n is length of tagString
%   intercept
%     n-by-2 matrix of intercepts in [left right; left right; ... ] format,
%     where n is length of tagString

slope = zeros(length(tags), 2);
intercept = zeros(length(tags), 2);
numBots = length(tags);

% For each bot
for i = 1:numBots
    % Left wheel
    % Max speed
    sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'SET_M_L', tags(i), 255);
    sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'SET_M_R', tags(i), 0);
    tic;
    sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'GO', tags(i));
    pause(1);
    sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'STOP', tags(i));
    elapsed = toc;
    leftTicks = sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'GET_T_L', tags(i));
    maxLeft = leftTicks*pi/(96*elapsed);
    % Intercept
    leftIntercept = 120;
    while leftTicks > 5
        leftIntercept = leftIntercept - 5;
        sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'SET_M_L', tags(i), leftIntercept);
        sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'GO', tags(i));
        pause(0.05);
        sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'STOP', tags(i));
        leftTicks = sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'GET_T_L', tags(i));
    end
    
    % Right wheel
    sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'SET_M_L', tags(i), 0);
    sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'SET_M_R', tags(i), 255);
    tic;
    sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'GO', tags(i));
    pause(1);
    sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'STOP', tags(i));
    elapsed = toc;
    rightTicks = sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'GET_T_R', tags(i));
    maxRight = rightTicks*pi/(96*elapsed);
    % Intercept
    rightIntercept = 120;
    while rightTicks > 5
        rightIntercept = rightIntercept - 5;
        sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'SET_M_R', tags(i), rightIntercept);
        sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'GO', tags(i));
        pause(0.05);
        sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'STOP', tags(i));
        rightTicks = sendInstruction(xbeeSerial,tagIdStruct,insStruct, 'GET_T_R', tags(i));
    end
    
    % Store data
    slope(i,:) = [(255-leftIntercept)/maxLeft (255-rightIntercept)/maxRight];
    intercept(i,:) = [leftIntercept rightIntercept];
end
