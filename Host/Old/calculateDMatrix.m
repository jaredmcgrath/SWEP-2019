function [DMatrix] = calculateDMatrix(adjMatrix)
%Determine the adjacency matrix's corresponding D matrix

DMatrix = eye(size(adjMatrix, 1));

for i = 1:size(adjMatrix, 1)
   DMatrix(i,i) =  sum(adjMatrix(1,:));
end

end

