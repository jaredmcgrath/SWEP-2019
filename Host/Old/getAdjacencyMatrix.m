function [adjMatrix] = getAdjacencyMatrix(position, botTag)
%Gets the adjacency matrix of the robots

%allow the user to choose how they want the adjacency matrix to be defined
choose = input('Do you want to have communication bubbles? Type ''y'' for yes, ''n'' to define your own adjacency matrix.', 's');

if (choose == 'y' || choose == 'Y')
    %Have the user choose the radius of the bubbles of communication
    dimension = input('Choose the size of communication bubbles.');
    adjMatrix = adjBubbles(position, dimension);
else
    adjMatrix = userAdjMatrix(botTag);
end

end

