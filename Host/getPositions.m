function [position,heading] = getPositions(config, tags)
%% getPositions
% Gets the position and heading of all specified bots
% TODO: Figure out a smart way to implement localization automatically
%
% Parameters:
%   config
%     The config struct (see parseConfig.m)
%   tags
%     Character vector of bot tag(s) to get position(s) from
%
% Returns:
%   position
%     n-by-2 position vector, where n is length of tags
%   heading
%     n-by-1 vector of bot orientation(s), counter-clockwise from the
%     positive x-axis

response = sendInstruction(config, 'G_GET_POS', tags);
position = response(:,1:2);
heading = response(:,3);

