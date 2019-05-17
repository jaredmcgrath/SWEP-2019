function [L] = CalculateL(A)
%% CalculateL
% This function calculates the Laplacian Matrix given the adjacency matrix.
% 
% Parameters:
%   A -- the adjacency matrix
%
% Returns:
%   L -- Laplacian Matrix

%% Function Code
numAgents = size(A,1);
D = diag(A*ones(numAgents,1));
L = D - A;
end