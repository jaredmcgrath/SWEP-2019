function mass = calcMass(agentPoints,density,partitions)
%% calcMass
% Calculates the mass of the observed region for each agent
%
% Parameters:
%   agentPoints
%     n-by-1 cell array, where cell i contains agent i's observed points
%   density
%     (sides*partitions)-by-(sides*partitions) matrix of the density for
%     the current iteration
%   partitions
%     Number of subdivisions within each unit length of the arena
%
% Returns:
%   mass
%     n-by-1 vector where the ith entry is the mass of agent i's observed
%     region

numAgents = size(agentPoints,1);
mass = zeros(numAgents,1);
% For each agent
for i = 1:numAgents
    % For each point in the agent's region
    for j = 1:size(agentPoints{i},1)
        x = floor(agentPoints{i}(j,1)*(partitions));
        y = floor(agentPoints{i}(j,2)*(partitions));
        if x > 0 && y > 0
            mass(i,1) = mass(i,1) + density(y,x);
        end
     end
end
