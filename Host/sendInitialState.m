function sendInitialState(config, positions, tags, heading)
%% sendInitialState
% Takes the initial position info for each bot and an XBee serial port
% object, sends the info, then asks all bots to confirm their status
%
% Parameters:
%   config
%     The config struct (see parseConfig.m)
%   positions
%     n-by-2 array of positions for n bots. Formatted [x1,y1;x2,y2;...]
%   tags
%     Character vector of the bots' tags that are being used. Should only
%     contain characters that are found in the bot tag list in the config
%     file. Each character represents one bot
%   heading
%     The heading of the positive x-axis in degrees
%
% Returns:
%   N/A

%% Main Code
numBots = length(tags);

for i = 1:numBots
    sendInstruction(config, 'SET_X', tags(i), positions(i,1));
    sendInstruction(config, 'SET_Y', tags(i), positions(i,2));
    sendInstruction(config, 'SET_H', tags(i), heading);
end
sendInstruction(config, 'G_CONF', numBots);