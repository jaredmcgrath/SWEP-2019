function [positions, tags, theta] = initializeBotState(config)
%% initializeBotState
% Query user for:
%   - Bot tags being used
%   - Each bot's initial position
%   - Heading of the positive x-axis
%
% Parameters:
%   config
%     The config struct (see parseConfig.m)
%
% Returns:
%   positions
%     n-by-2 array of positions for n bots. Formatted [x1,y1;x2,y2;...]
%   tags
%     Character vector of the bots' tags that are being used. Should only
%     contain characters that are found in the bot tag list in the config
%     file. Each character represents one bot
%   theta
%     The initial thetas for all bots

% Get tags being used
tags = upper(input('Enter bot tags being used: ','s'));
while isempty(tags) || ~arrayfun(@(i) contains(config.validTags,tags(i)), length(tags))
    disp(['Must be any combination of: ' config.validTags]);
    tags = upper(input('Enter bot tags being used: ','s'));
end
theta = zeros(length(tags),1);
positions = zeros(length(tags),2);
% Input the staritng cooridinates for each robot
disp('Input coordinates in meters to 2 decimal places')
for i = 1:length(tags)
    positions(i,1) = input(['Enter x for ' tags(i) ': ']);
    while (positions(i,1) > config.maxX)
        disp(['Must have x less than ' num2str(config.maxX)]);
        positions(i,1) = input(['Enter x for ' tags(i) ': ']);
    end
    positions(i,2) = input(['Enter y for ' tags(i) ': ']);
    while (positions(i,2) > config.maxY)
        disp(['Must have y less than ' num2str(config.maxY)]);
        positions(i,2) = input(['Enter y for ' tags(i) ': ']);
    end
    theta(i) = (pi/180)*input(['Enter initial theta (degrees) for ' tags(i) ': ']);
    while 0 > theta(i) || theta(i) > 2*pi
        disp('Please enter theta between 0 to 360');
        theta(i) = (pi/180)*input(['Enter initial theta (degrees) for ' tags(i) ': ']);
    end
end
