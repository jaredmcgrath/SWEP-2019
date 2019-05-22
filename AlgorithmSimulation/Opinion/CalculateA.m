function [A] = CalculateA(nodeData)
%% CalculateA
% This function is to calculate the adjacecny matrix given each node's
% position, radius of communication and left and right noise values
%
%   Parameters:
%       nodeData 
%           the x, y, radius, left noise and right noise data for
%           each node in the simulation (n x 5 matrix where n is the number
%           of nodes)
%
%   Returns: 
%       A
%           the resulting adjacency matrix (n x n matrix where n is the
%           number of nodes)

%% Function Code
nodePosition = nodeData(:,1:2);
radii = nodeData(:,3);
leftNoise = nodeData(:,4);
rightNoise = nodeData(:,5);

dist = pdist2(nodePosition,nodePosition);

relativePosition = nodePosition(:,1)' - nodePosition(:,1);

A = (relativePosition <= 0 & dist <= (radii-leftNoise)) | (relativePosition >= 0 & dist <= (radii-rightNoise));
end

