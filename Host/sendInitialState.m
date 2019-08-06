function overlapResponses = sendInitialState(config, positions, tags, theta)
%% sendInitialState
% Takes the initial position info for each bot and an XBee serial port
% object and sends the info
%
% Parameters:
%   config
%     Config struct (see parseConfig.m)
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
%   overlapResponses
%     Array of XBeeResponse objects that were received during this
%     instruction, but should be handled as independent requests by the
%     calling function

overlapResponses = XBeeResponse.empty;
for i = 1:length(tags)
    [~, overlap] = sendInstruction(config, 'SET_POS', tags(i),...
        [positions(i,:) theta(i)]);
    overlapResponses = [overlapResponses overlap];
end
