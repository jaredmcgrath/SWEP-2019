function [adjMatrix] = adjBubbles(position, dimension)
%Determines the adjaceny matrix by how close each bot is to each other

adjMatrix = eye(size(position, 1));

%Iterate through every element of the adjacency matrix
for i = 1:size(position, 1)
    for j = 1:size(position, 1)
        if (i ~= j)
            %calculate the distance between the ith and jth robot
            dist = sqrt((position(j,2) - position(i,2))^2 + (position(j,1) - position(i,1))^2);
            
            %if the distance between them is less than or equal to the
            %dimension of the communication bubbles, then write a 1 to the
            %adjacency matrix
            if (dist <= dimension)
                adjMatrix(i,j) = 1;
            end
        end
    end
end

end

