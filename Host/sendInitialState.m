function sendInitialState(xbeeSerial, botPositionArray, botTagString, heading)
%% sendInitialState
% Takes the initial position info for each bot and an XBee serial port
% object, sends the info, then asks all bots to confirm their status
%
% Parameters:
%   xbeeSerial
%     Serial port object for the XBee. The serial port should be closed
%     upon calling sendInitialState
%   botPositionArray
%     n-by-2 array of positions for n bots. Formatted [x1,y1;x2,y2;...]
%   botTagString
%     String of the bots' tags that are being used. Should only contain
%     characters that are found in the bot tag list in the config file.
%     Each character represents one bot
%   heading
%     The heading of the positive x-axis in degrees
%
% Returns:
%   N/A

for iBot = 1:length(botTagString)
    sendInstruction(xbeeSerial, 'SET_X', botTagString(iBot), botPositionArray(iBot,1));
    sendInstruction(xbeeSerial, 'SET_Y', botTagString(iBot), botPositionArray(iBot,2));
    sendInstruction(xbeeSerial, 'SET_H', botTagString(iBot), heading);
end
sendInstruction(xbeeSerial, 'G_CONF');