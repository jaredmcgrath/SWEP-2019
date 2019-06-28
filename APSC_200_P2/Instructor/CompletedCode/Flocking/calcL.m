function L = calcL(A)
%% calcL
% Calculates the Laplacian matrix given the adjacency matrix.
% 
% Parameters:
%   A
%     The n-by-n adjacency matrix
%
% Returns:
%   L
%     The n-by-n Laplacian matrix

numAgents = size(A,1);
D = diag(A*ones(numAgents,1));
L = D - A;
