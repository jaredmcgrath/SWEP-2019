function [commCells,adjMatrix] = communication(agentPositions,rComm)
%% communication
% Determines the adjacency matrix and communication cells of all agents
%
% Parameters:
%   agentPositions
%     n-by-2 vector of the x, y positions for n agents
%   rComm
%     Radius of communication for all agents
%
% Returns:
%   commCells
%     Cell array, where each cell is one communication group
%   adjMatrix
%     The symmetric adjacency matrix 

numAgents = size(agentPositions, 1);

% Calculate adjacency matrix
adjMatrix = zeros(numAgents,numAgents);
for i = 1:numAgents
    for j = i:numAgents
        if (agentPositions(j,1)-agentPositions(i,1))^2 + ...
                (agentPositions(j,2)-agentPositions(i,2))^2 <= rComm^2
            adjMatrix(i,j) = 1;
            adjMatrix(j,i) = 1;
        end
    end
end
% Calculate the communication cells
G = graph(adjMatrix);
commCells = conncomp(G,'OutputForm','cell');
