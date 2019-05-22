function L = calcL(A)
%% CalculateL
% This function calculates the Laplacian Matrix given the adjacency matrix.
% 
% Parameters:
%   A
%     Adjacency matrix (n x n matrix where n is the number of nodes) 
%
% Returns:
%   L
%     Laplacian Matrix (n x n matrix where n is the number of nodes)

numAgents = size(A,1);
D = diag(A*ones(numAgents,1));
L = D - A;
