function [LaplacianMatrix] = getLaplacianMatrix(adjMatrix,DMatrix)
% Calculate the Laplacian matrix of the system from the adjacency and D
% matrices

LaplacianMatrix = zeros(size(adjMatrix, 1), size(adjMatrix, 1));
for i = 1:size(adjMatrix, 1)
    normalizer = DMatrix(i,i);
    for j = 1:size(adjMatrix, 1)
        LaplacianMatrix(i,j) = (DMatrix(i,j) - adjMatrix(i,j))/normalizer;
    end
end

end

