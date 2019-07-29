function [slope, intercept] = calibrateWheels(config, tags)
%% calibrateWheels
% Calibrate robots by determining the slopes and intercepts from encoder
% ticks
%
% Parameters:
%   serialPort
%     The config struct (see parseConfig.m)
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
    sendInstruction(config, 'SET_M_L', tags(i), 255);
    sendInstruction(config, 'SET_M_R', tags(i), 0);
    tic;
    sendInstruction(config, 'GO', tags(i));
    pause(1);
    sendInstruction(config, 'STOP', tags(i));
    elapsed = toc;
    leftTicks = sendInstruction(config, 'GET_T_L', tags(i));
    maxLeft = leftTicks*pi/(96*elapsed);
    % Intercept
    leftIntercept = 150;
    while leftTicks > 10
        leftIntercept = leftIntercept - 5;
        sendInstruction(config, 'SET_M_L', tags(i), leftIntercept);
        sendInstruction(config, 'GO', tags(i));
        pause(0.05);
        sendInstruction(config, 'STOP', tags(i));
        leftTicks = sendInstruction(config, 'GET_T_L', tags(i));
    end
    
    % Right wheel
    sendInstruction(config, 'SET_M_L', tags(i), 0);
    sendInstruction(config, 'SET_M_R', tags(i), 255);
    tic;
    sendInstruction(config, 'GO', tags(i));
    pause(1);
    sendInstruction(config, 'STOP', tags(i));
    elapsed = toc;
    rightTicks = sendInstruction(config, 'GET_T_R', tags(i));
    maxRight = rightTicks*pi/(96*elapsed);
    % Intercept
    rightIntercept = 150;
    while rightTicks > 10
        rightIntercept = rightIntercept - 5;
        sendInstruction(config, 'SET_M_R', tags(i), rightIntercept);
        sendInstruction(config, 'GO', tags(i));
        pause(0.05);
        sendInstruction(config, 'STOP', tags(i));
        rightTicks = sendInstruction(config, 'GET_T_R', tags(i));
    end
    
    % Store data
    slope(i,:) = [(255-leftIntercept)/maxLeft (255-rightIntercept)/maxRight];
    intercept(i,:) = [leftIntercept rightIntercept];
end
