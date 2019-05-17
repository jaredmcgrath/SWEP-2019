function centroids = calcCentroids(agentPoints, mass, density,...
    agentPositions, partitions)
%% calcCentroids
% Calculates the centroid of each agent's observed region
%
% Parameters:
%   agentPoints
%     n-by-1 cell array, where cell i contains agent i's observed points
%   mass
%     n-by-1 vector where the ith entry is the mass of agent i's observed
%     region
%   density
%     (sides*partitions)-by-(sides*partitions) matrix of the density for
%     the current iteration
%   agentPositions
%     n-by-2 vector of the x, y positions for n agents
%   partitions
%     Number of subdivisions within each unit length of the arena
%
% Returns:
%   centroids
%     n-by-2 vector of the x, y positions of the centroids of each region
numAgents = size(agentPositions,1);
centroids = zeros(numAgents,2);
centroidSum = zeros(numAgents,2);
% For each agent
for i = 1:numAgents
    % For each point in the region
    for j = 1:size(agentPoints{i},1)
        % Calculate actual position and sum density
        pos = agentPoints{i}(j,:);
        D = floor(pos*partitions);
        if min(D)>0
            centroidSum(i,:) = centroidSum(i,:) + pos*density(D(1),D(2));
        end
    end
    % If agent has mass in region, move towards centroid
    if mass(i)
        centroids(i,:) = centroidSum(i,:)/mass(i);
    % Otherwise, centroid = agentPosition
    else
        centroids(i,:) = agentPositions(i,:);
    end
end
