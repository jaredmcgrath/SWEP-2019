function centroids = calcCentroids(agentPoints, mass, D, numAgents,...
agentPositions, partitions)
% centroids is a nx2 matrix, where (i,1) and (i,2) represent the ith
% agent's centroid's x and y value, respectively.

% Calculates Sum(x*D(x,y)), then divides by mass to get x centroid, does 
% the same to get y centroid. This follows the accepted equation for
% centroid of an area. 

centroids = zeros(numAgents, 2);
centroidSum = zeros(numAgents, 2);
 
for i = 1:numAgents 
    for j = 1:size(agentPoints{1,i},1)
        x_D = floor(agentPoints{1,i}(j,1)*(partitions));
        y_D = floor(agentPoints{1,i}(j,2)*(partitions));
        x = agentPoints{1,i}(j,1);
        y = agentPoints{1,i}(j,2);
        if x_D > 0 && y_D > 0
            centroidSum(i,1) = centroidSum(i,1) + x*D(x_D,y_D);
            centroidSum(i,2) = centroidSum(i,2) + y*D(x_D,y_D);
        end
    end
end

for i = 1:numAgents
    if mass(i) == 0 % If robot has no surrounding mass then don't move it.
        centroids(i,1) = agentPositions(i,1);
        centroids(i,2) = agentPositions(i,2);
    else % Otherwise, calculate the centroid.
        centroids(i,1) = centroidSum(i,1)/mass(i);
        centroids(i,2) = centroidSum(i,2)/mass(i);
    end
end
