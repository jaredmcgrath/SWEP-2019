function controlInput = getControlInputs(config, position, heading,...
    desiredPosition, slope, intercept)
%% getControlInputs
% Determines the proper control inputs to move bots to their desired
% positions
%
% Parameters:
%   config
%     The config struct (see parseConfig.m)
%   position
%     n-by-2 vector of current positions for n agents
%   heading
%     n-by-1 vector of bot orientation(s), counter-clockwise from the
%     positive x-axis
%   desiredPosition
%     n-by-2 vector of desired positions for n agents
%   slope
%     n-by-2 matrix of slopes in [left right; left right; ... ] format,
%     where n is length of tagString
%   intercept
%     n-by-2 matrix of intercepts in [left right; left right; ... ] format,
%     where n is length of tagString
%
% Returns:
%   controlInput
%     n-by-2 vector of control inputs (-255<=input<=255) in 
%     [L1 R1; L2 R2; ... ] format

% TODO: Figure out how old code worked and rewrite it here
controlInput = zeros(size(position));
