function [botPositionArray, tags, heading] = initializeBotState(config)
%% initializeBotState
% Query user for:
%   - Bot tags
%   - Each bot's initial position
%   - Heading of the positive x-axis
%
% Parameters:
%   maxX
%     The maximum x value boundary in meters, usually 5.12
%   maxY
%     The maximum y value boundary in meters, usually 5.12
%
% Returns:
%   botPositionArray
%     n-by-2 array of positions for n bots. Formatted [x1,y1;x2,y2;...]
%   tags
%     Character vector of the bots' tags that are being used. Should only
%     contain characters that are found in the bot tag list in the config
%     file. Each character represents one bot
%   heading
%     The heading of the positive x-axis in degrees

% Extract info from config
maxXNodes = config.getElementsByTagName('maxX');
maxXNode = maxXNodes.item(0);
maxX = str2num(maxXNode.getFirstChild.getData);
maxYNodes = config.getElementsByTagName('maxY');
maxYNode = maxYNodes.item(0);
maxY = str2num(maxYNode.getFirstChild.getData);
tagNodes = config.getElementsByTagName('tag');
validBotString = '';
for i = 0:tagNodes.getLength-1
    bot = tagNodes.item(i);
    validBotString = cat(2,validBotString,char(bot.getFirstChild.getData));
end

% Input the staritng cooridinates for each robot
disp('Input coordinates in meters to 2 decimal places')
for iBot = 1:length(tags)
    botPositionArray(iBot,1) = input(['Enter x for ' tags(iBot) ': ']);
    while (botPositionArray(iBot,1) > maxX)
        disp(['Must have x less than ' maxX])
        botPositionArray(iBot,1) = input(['Enter x for ' tags(iBot) ': ']);
    end
    botPositionArray(iBot,2) = input(['Enter y for ' tags(iBot) ': ']);
    while (botPositionArray(iBot,2) > maxY)
        disp(['Must have y less than ' maxY])
        botPositionArray(iBot,2) = input(['Enter y for ' tags(iBot) ': ']);
    end
end

% Input the heading in degrees for the x-axis for the coordinate system
heading = input('Input heading of positive x-axis in degrees: ');
