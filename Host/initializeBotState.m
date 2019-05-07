function [botPositionArray, botTagString, heading] = initializeBotState(maxX, maxY)
%% initializeBotState
% This function is responsible for getting the tags of bots being used
% and their initial x, y, and theta w.r.t. positive x-axis
%
% Get initial position of all of the robots and the general baseline for the
% axis frame, the heading of the axis frame needs to be calculated from a
% compass or phone app
%% TODO: Param/return docs
botTagString = input('Enter bot tags: ', 's');
botPositionArray = zeros(length(botTagString), 2);
disp('Input coordinates in meters to 2 decimal places')
for iBot = 1:length(botTagString)
    botPositionArray(iBot,1) = input(['Enter x for ' botTagString(iBot)]);
    while (botPositionArray(iBot,1) > maxX)
        disp(['Must have x less than ' maxX])
        botPositionArray(iBot,1) = input(['Enter x for ' botTagString(iBot)]);
    end
    botPositionArray(iBot,2) = input(['Enter y for ' botTagString(iBot)]);
    while (botPositionArray(iBot,2) > maxY)
        disp(['Must have y less than ' maxY])
        botPositionArray(iBot,2) = input(['Enter y for ' botTagString(iBot)]);
    end
end
heading = input('Input heading of positive x-axis in degrees N');
