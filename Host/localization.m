function [newPosition] = localization(rssi,xBot,yBot)
% LOCALIZATION: This function takes in the rssi readings and the position
% of the robots based on dead reckoning and returns the new positions of 
% the robots
%   This function takes

dist = 0.0854.*rssi.^2+1.8452.*rssi-1.0415;


end

