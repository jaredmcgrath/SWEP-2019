function A = calcA(agentPosition)
%% calcA
% Calculates the adjacency matrix, A, from the agent state
%
% Parameters:
%   agentPosition
%     n-by-2 vector of (x,y) positions for n agents. This is the 'state'
%     vector of the agents, q, on which the adjacency matrix is calculated
%
% Returns:
%   A
%     The n-by-n adjacency matrix
