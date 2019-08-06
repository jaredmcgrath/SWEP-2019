function [position] = localization(config,rssi)
%% localization
%   This function takes the received RSSI values and converts the values
%   into distances. These distances are then used in the min-max
%   localization method to determine the position of the robot(s). This
%   position is then fused with that from the deadreckoning to determine
%   the most probable location of the robot
%
% Parameters:
%   config
%     Config struct (see parseConfig.m)
%   rssi
%     m x n matrix where m denotes the number of robots and n denotes the 
%     number of beacons
%
% Returns:
%   position
%     m x 2 position vector of robots after localization

% Obtains distances from RSSI readings. rssi is a m x n matrix where m
% denotes the number of robots and n denotes the number of beacons
dist = (0.0854.*rssi.^2+1.8452.*rssi-1.0415)./100;

% Set up global mesh grid
[X,Y] = meshgrid(-config.maxX:0.03:config.maxX, -config.maxY:0.03:config.maxY);

for i = 1:size(dist,1)
    overlap = ones(length(X),length(Y));
    for j = 1:size(dist,2)
        % Create a square originating at each beacon with given distance
        square = BeaconSquare(config.beaconPositions(j,:), dist(i,j));
        overlap = overlap & inpolygon(X, Y, square.xVertices,...
            square.yVertices);
    end
    % Logical or across columns
    overlapX = any(overlap);
    % Logical or accross rows
    overlapY = any(overlap,2);
    x1 = X(1,find(overlapX,1));
    x2 = X(1,find(overlapX,1,'last'));
    y1 = Y(find(overlapY,1),1);
    y2 = Y(find(overlapY,1,'last'),1);
    position(i,1:2) = [mean([x1 x2]) mean([y1 y2])];
end
