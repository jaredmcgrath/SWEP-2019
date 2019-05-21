function [A] = CalculateA(nodeData)
%% CalculateA
% This function is to calculate the adjacecny matrix given each node's
% position, radius of communication and left and right noise values
%
%   Parameters:
%       nodeData 
%           the x, y, radius, left noise and right noise data for
%           each node in the simulation
%
%   Returns: 
%       A
%           the resulting adjacency matrix

%% Function Code
nodePosition = nodeData(:,1:2);
radii = nodeData(:,3);
leftNoise = nodeData(:,4);
rightNoise = nodeData(:,5);

dist = pdist2(nodePosition,nodePosition);

A = dist < (radii-leftNoise) | dist < (radii-rightNoise);
end

