function [nodeDataUpdated] = UpdateNodeData(nodeData, L, timeStep, iteration)
%% UpdateNodeData
% This function updates the nodedata for each iteration
%   
%   Parameters:
%       nodeData
%           the x, y, radii, left noise and right noise data for each node
%           in the simulation (n x 5 matrix where n is the number of nodes)
%       L
%           the Laplacian matrix calculated for this iteration
%
%   Returns:
%       nodeDataUpdated
%           updated x, y, radii, left noise and right noise data that will
%           be returned to the app (n x 5 matrix where n is the number of
%           nodes)

%% Function Code

nodePosition = nodeData(:,1:2);
%nodeRadii = nodeData(:,3);
%nodeNoise = nodeData(:,4:5);

nodeDataUpdated = nodeData;

nodeDataUpdated(:,1:2) = nodePosition - timeStep*L*nodePosition;
end

