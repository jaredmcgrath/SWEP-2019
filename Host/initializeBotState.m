function [botPositionArray, botTagString, heading] = initializeBotState(config)
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
%   botTagString
%     String of the bots' tags that are being used. Should only contain
%     characters that are found in the bot tag list in the config file.
%     Each character represents one bot
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
for i = 0:tagNodes.getLength
    bot = tagNodes.item(i);
    validBotString = validBotString + char(bot.getFirstChild.getData);
end

botTagString = input('Enter bot tags: ', 's');
botPositionArray = zeros(length(botTagString), 2);
disp('Input coordinates in meters to 2 decimal places')
for iBot = 1:length(botTagString)
    botPositionArray(iBot,1) = input(['Enter x for ' botTagString(iBot) ': ']);
    while (botPositionArray(iBot,1) > maxX)
        disp(['Must have x less than ' maxX])
        botPositionArray(iBot,1) = input(['Enter x for ' botTagString(iBot) ': ']);
    end
    botPositionArray(iBot,2) = input(['Enter y for ' botTagString(iBot) ': ']);
    while (botPositionArray(iBot,2) > maxY)
        disp(['Must have y less than ' maxY])
        botPositionArray(iBot,2) = input(['Enter y for ' botTagString(iBot) ': ']);
    end
end
heading = input('Input heading of positive x-axis in degrees: ');
