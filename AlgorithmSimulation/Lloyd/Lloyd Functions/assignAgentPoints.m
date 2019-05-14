function agentPoints = assignAgentPoints(agentPositions, commCells, sides,...
    partitions,rObs,E)
%% TODO: Fix this function
% Assign points based on communication cells:
%   - Group every observed point of all agents in a comm cell together
%   - Calculate the distance between each point in the group and all agents
%     in that cell
%   - Assign that point to the agent that is closest

numAgents = size(agentPositions,1);
agentPoints = cell(numAgents,1);
[X, Y] = meshgrid(1:sides*partitions, 1:sides*partitions);
% Generate a list of all points for rangesearch
allPoints = [reshape(X, [sides*partitions 1]) ...
    reshape(Y, [sides*partitions 1])]/partitions;
% For each commCell
for commCell = commCells
    [idx, dist] = rangesearch(allPoints, agentPositions(commCell,:), rObs);
    
    % cellIndexes is a temp to hold final indexes of allPoints for each
    % agent, removing duplicate points within same commCell
    cellIndexes = commCell(size(commCell,1));
    for i = 1:size(commCell,1)
        
    end
end

