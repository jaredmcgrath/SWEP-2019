function A = calcA(k, sigma, beta, agentPosition)
%% calcA
% This function calculates the A matrix based on the given equation using
% the user defined parameters and the positions of each agent
%   The equation to calculate A(i,j) is
%                               K
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
%     n-by-2 position matrix for n agents in [x1 y1; x2 y2;...] format
%
% Returns:
%   A
%     Adjacnecy matrix
%% Your Code Below
