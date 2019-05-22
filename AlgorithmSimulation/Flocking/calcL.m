function L = calcL(A)
%% calcL
% Calculates Laplacian Matrix from adjacency matrix.
% 
% Parameters:
%   A
%     Adjacency matrix
%
% Returns:
%   L
%     Laplacian Matrix

numAgents = size(A,1);
D = diag(A*ones(numAgents,1));
L = D - A;
