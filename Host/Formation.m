function [newPosition] = Formation(bots, position)
%Formation Algorithm, adapted from the formation gui

%Use the constructed functions to determine all of the necessary matrices
adjMatrix = getAdjacencyMatrix(position, bots);
DMatrix = calculateDMatrix(adjMatrix);
LaplacianMatrix = getLaplacianMatrix(adjMatrix, DMatrix);

newPosition = zeros(length(bots), 2);

%Iterate through every bot to determine its new position as a weighted
%average from the adjaceny matrix and all of the current positions
for i = 1:length(bots)
    newPosition(i, 1) = (-1*LaplacianMatrix(i, :))*position(:, 1);
    newPosition(i, 2) = (-1*LaplacianMatrix(i, :))*position(:, 2);
end

end

