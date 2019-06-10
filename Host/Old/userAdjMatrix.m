function [adjMatrix] = userAdjMatrix(botTag)
%Iterates through the number of robots twice to fill the square adjacency
%matrix with user inputs

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

