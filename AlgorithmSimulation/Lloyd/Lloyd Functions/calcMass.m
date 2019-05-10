function mass = calcMass(agentPoints,D,numAgents,partitions)
% Outputs a vector with the mass of the region of agent i stored in 
% mass(i).
% D is a sides*partitions-by-sides*partitions matrix of density values
% where the entry of the matrix at i,j is the value of the density at 
% (i/p,j/p)
mass = zeros(1,numAgents);
for i = 1:numAgents
    for j = 1:size(agentPoints{1,i},1)
        x = floor(agentPoints{1,i}(j,1)*(partitions));
        y = floor(agentPoints{1,i}(j,2)*(partitions));
        if x > 0 && y > 0
            mass(i) = mass(i) + D(x,y);
        end
     end
end
