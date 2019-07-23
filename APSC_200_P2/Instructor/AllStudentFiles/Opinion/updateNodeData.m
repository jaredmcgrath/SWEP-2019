function nodeData = updateNodeData(nodeData, L, dt, time)
%% updateNodeData
% Updates nodeData (rComm, position(s), leftNoise and/or rightNoise)
% for each iteration
% If simulation is 1D, each row of nodeData is 
% [rComm,position,leftNoise,rightNoise]
% If simulation is 2D, each row of nodeData is
% [rComm,xPosition,yPosition]
%
% Parameters:
%   nodeData 
%     Matrix of data for all nodes in format specified above, depending on
%     simulations dimension(s), before update
%   L
%     Laplacian matrix calculated for this iteration
%   dt
%     Simulated time step
%   time
%     The current time
%
% Returns:
%   nodeData 
%     Matrix of data for all nodes in format specified above, depending on
%     simulations dimension(s), after update
