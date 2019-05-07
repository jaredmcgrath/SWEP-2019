function sendInitialState(xbeeSerial, botPositionArray, botTagString, heading)
%% sendInitialState
% Send inital x, y, and heading to bots
%%
for iBot = 1:length(botTagString)
    sendInstruction(xbeeSerial, 'SET_X', botTagString(iBot), botPositionArray(iBot,1));
    sendInstruction(xbeeSerial, 'SET_Y', botTagString(iBot), botPositionArray(iBot,2));
    sendInstruction(xbeeSerial, 'SET_H', botTagString(iBot), heading);
end
sendInstruction(xbeeSerial, 'G_CONF');