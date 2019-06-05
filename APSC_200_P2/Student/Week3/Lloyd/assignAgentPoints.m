function agentPoints = assignAgentPoints(agentPositions, commCells, sides,...
    partitions,rObs)
%% assignAgentPoints
% Determine which points within an agent's observed region it is assigned.
% Agents in  the same communication cell will not be assigned the same
% point. However, agents who cannot communicate may cover the same point(s)
%
% Parameters:
%   agentPositions
%     n-by-2 vector of the x, y positions for n agents
%   commCells
%     Cell array, where each cell is one communication group
%   sides
%     Side length of arena
%   partitions
%     Number of subdivisions within each unit length of the arena
%   rObs
%     Radius of observation for all agents
%
% Returns:
%   agentPoints
%     Cell array with each cell containing an ni-by-2 vector of (x,y)
%     points that the ith agent is assigned
%% Your Code Below
