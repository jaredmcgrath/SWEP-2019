function lapMatrix = calcLaplacian(position,botTag)
%% calcLaplacian
%   This function determines the user defined adjacnecy matrix and then
%   calculates the corresponding Laplacian matrix

%% Adjacency Matrix
% Gets the adjacency matrix of the robots

% Allow the user to choose how they want the adjacency matrix to be defined
choose = input('Do you want to have communication bubbles? Type ''y'' for yes, ''n'' to define your own adjacency matrix.', 's');

if (choose == 'y' || choose == 'Y')
    % Runs if the user chose to define the radius of the bubbles of 
    % communication
    dimension = input('Choose the size of communication bubbles.');
    adjMatrix = pdist2(position,position) <= dimension;
    
else
    % Runs if the user chose to not define a radius of communication for 
    % the agents. 
    
    adjMatrix = zeros(length(botTag), length(botTag));
    for i = 1:length(botTag)
        for j = 1:length(botTag)
            if (i == j)
                adjMatrix(i,j) = input('Input the robots ''trust'' value for its own position. This is recommended to be at least 1.');
            else
                adjMatrix(i,j) = input(['Input how much robot ' botTag(i) ' trusts ' botTag(j) '.']);
            end
        end
    end
end

%% Laplacian Matrix 
dMatrix = diag(adjMatrix*ones(size(adjMatrix,1)));
lapMatrix = dMatrix - adjMatrix;

end

