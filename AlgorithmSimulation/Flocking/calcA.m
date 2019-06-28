function A = calcA(k, sigma, beta, agentPosition)
%% calcA
% This function calculates the A matrix based on the given equation using
% the user defined parameters and the positions of each agent
%   The equation to calculate A(i,j) is
%                               k
%               A = -----------------------------
%                   (sigma^2 + dist(i,j)^2)^beta
%
% Parameters:
%   k
%     Constant scalar multiplier
%   sigma
%     Offset value
%   beta
%     Exponent
%   agentPosition
%     n-by-2 vector of (x,y) positions for n agents. This is the 'state'
%     vector of the agents, q, on which the adjacency matrix is calculated
%
% Returns:
%   A
%     The n-by-n adjacnecy matrix

% Calculate the distance an agent is from every other agent
dist = pdist2(agentPosition,agentPosition); 
% Calculating the adjacency matrix
A = k*((sigma^2 + dist.^2).^beta).^-1;
