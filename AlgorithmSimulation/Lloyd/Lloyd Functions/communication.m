function [commCells,adjMatrix] = communication(agentPositions,rComm,numAgents)
%% communication
% Determines the adjacency matrix and communication cells of all agents

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
