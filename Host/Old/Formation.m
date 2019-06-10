function [newPosition] = Formation(bots, position, algorithm, algorithmParameters)
%Formation Algorithm, adapted from the formation gui

if algorithm == 1
    adjMatrix = algorithmParameters;
elseif algorithm == 2
    radii = algorithmParameters;
    adjMatrix = pdist2(position,position) <= radii;
else 
    adjMatrix = eye(size(position,1));
end

% Calcualtes degree matrix, then Laplacian Matrix
dMatrix = diag(adjMatrix*ones(size(position,1)));
laplacianMatrix = dMatrix - adjMatrix;

% Calculating the new position for each robot (assuming a time step of 1,
% which is most likely incorrect -- NEED TO FIX THIS)
newPosition = position - laplacianMatrix*position;

%% NOT SURE WHAT THIS SECTION IS DOING (from original code)
%{
%Iterate through every bot to determine its new position as a weighted
%average from the adjaceny matrix and all of the current positions
for i = 1:length(bots)
    newPosition(i, 1) = (-1*laplacianMatrix(i, :))*position(:, 1);
    newPosition(i, 2) = (-1*laplacianMatrix(i, :))*position(:, 2);
end
%}
end

