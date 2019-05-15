function coverage = calcCoverage(agentPoints, sides, partitions)
%% coverage
% Calculates how much of the arena is being observed as a percentage
%
% Parameters:
%   agentPoints
%     n-by-1 cell array, where each cell is ni-by-2 list of (x,y) points
%     the ith agent is observing
%   sides
%     Side length of the arena
%   partitions
%     Number of subdivisions within each unit length of the arena
%
% Returns
%   coverage
%     Percent value between 0 and 1 representing coverage

numPoints = (sides*partitions)^2;
assignedPoints = arrayfun(@(col) vertcat(agentPoints{:, col}),...
    1:size(agentPoints, 2), 'UniformOutput', false);
numAssigned = size(unique(assignedPoints{1},'rows'), 1);
coverage = numAssigned/numPoints;
