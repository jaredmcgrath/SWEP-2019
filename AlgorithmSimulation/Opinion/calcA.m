function A = calcA(nodeData)
%% calcA
% Calculate adjacency matrix from node data
% If simulation is 1D, each row of nodeData is 
% [rComm,position,leftNoise,rightNoise]
% If simulation is 2D, each row of nodeData is
% [rComm,xPosition,yPosition]
%
% Parameters:
%   nodeData 
%     Matrix of data for all nodes in format specified above, depending on
%     simulations dimension(s)
%
% Returns: 
%   A
%     Adjacency matrix

nodePosition = nodeData(:,2);
radii = nodeData(:,1);
leftNoise = nodeData(:,3);
rightNoise = nodeData(:,4);

dist = pdist2(nodePosition,nodePosition);

relativePosition = nodePosition(:,1)' - nodePosition(:,1);

A = (relativePosition <= 0 & dist <= (radii-leftNoise)) | (relativePosition >= 0 & dist <= (radii-rightNoise));
