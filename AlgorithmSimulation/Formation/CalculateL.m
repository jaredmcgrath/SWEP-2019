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

num_agents = size(A,1);
D = zeros(num_agents);

for i = 1:num_agents
    for j = 1:num_agents
        D(i,i) = D(i,i) + A(i,j);
    end
end

L = D - A;
end

