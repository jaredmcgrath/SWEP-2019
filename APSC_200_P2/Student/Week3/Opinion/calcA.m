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
%% Your Code Below
