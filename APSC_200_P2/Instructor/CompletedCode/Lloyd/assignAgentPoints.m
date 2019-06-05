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

numAgents = size(agentPositions,1);
agentPoints = cell(numAgents,1);
[X, Y] = meshgrid(1:sides*partitions, 1:sides*partitions);
% Generate a list of all points for rangesearch
allPoints = [reshape(X, [(sides*partitions)^2 1]) ...
    reshape(Y, [(sides*partitions)^2 1])]/partitions;
% For each commCell
for iComm = 1:size(commCells,2)
    commCell = commCells{iComm};
    [idx, dist] = rangesearch(allPoints, agentPositions(commCell,:), rObs);
    % sortedIndexes formats indexes, distance, and agent # in an m-by-3
    % matrix to sort by distance and retain info about the point and agent
    % it belongs to
    totalSize = sum(cellfun(@numel,idx));
    % Pre-allocate for speed
    sortedIndexes = zeros(totalSize,3);
    % Populate first agent before loop
    sortedIndexes(1:size(idx{1},2),:) = [idx{1}' dist{1}' ones(size(idx{1},2),1)];
    s = size(idx{1},2);
    for i = 2:size(commCell,1)
        e = size(idx{i},2);
        sortedIndexes(s+1:s+e,:) = [idx{i}' dist{i}' i*ones(size(idx{i},2),1)];
        s = s + e;
    end
    % Sort rows by distance in column 2
    sortedIndexes = sortrows(sortedIndexes,2);
    % Remove duplicates
    [~, iKeep, ~] = unique(sortedIndexes(:,1),'first');
    % Remove distance metric and sort by agent #
    keepIndexes = sortrows(sortedIndexes(iKeep,[1 3]),2);
    % Get a count of how many points each agent has
    counts = histcounts(keepIndexes(:,2),1:size(commCell,1)+1);
    % Keep track of where we are within keepIndexes
    lastIdx = 0;
    for i = 1:size(commCell,1)
        % Populate agent's cell with points from allPoints using
        % keepIndexes that have their agent number
        agentPoints{commCell(i)} = allPoints(keepIndexes(lastIdx+1:...
            lastIdx+counts(i)),:);
        lastIdx = lastIdx + counts(i);
    end
end
