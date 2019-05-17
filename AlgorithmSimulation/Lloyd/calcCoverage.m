function coverage = calcCoverage(agentPoints, partitions, density,...
    totalMass)
%% coverage
% Calculates how much of the arena is being observed as a percentage.
% Considers a weighted average of the density matrix.
%
% Parameters:
%   agentPoints
%     n-by-1 cell array, where each cell is ni-by-2 list of (x,y) points
%     the ith agent is observing
%   partitions
%     Number of subdivisions within each unit length of the arena
%   density
%     (sides*partitions)-by-(sides*partitions) matrix of the density for
%     the current iteration
%   totalMass
%     Mass of entire arena
%
% Returns
%   coverage
%     Percent value between 0 and 1 representing coverage

allPointsCell = arrayfun(@(col) vertcat(agentPoints{:, col}),...
    1:size(agentPoints, 2), 'UniformOutput', false);
allPoints = unique(allPointsCell{1},'first','rows');
coveredMass = sum(density( sub2ind(size(density),...
    partitions*allPoints(:,2), partitions*allPoints(:,1)) ), 'all');
coverage = coveredMass/totalMass;
