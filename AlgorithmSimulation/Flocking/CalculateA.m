function [A] = CalculateA(k,sigma,beta,agentPosition)
%% Calculate A 
% This function calculates the A matrix based on the given equation using
% the user defined parameters and the positions of each agent
%   The equation to calculate A(i,j) is
%                               K
%               A = -----------------------------
%                   (sigma^2 + dist(i,j)^2)^beta
%
%   Parameters:
%       k -- user defined parameter 
%       sigma -- user defined parameter
%       beta -- user defined parameter
%       agentPosition -- (number of Agents x 2) matrix of x,y position
%           information for each agent
%
%   Returns:
%       A -- the adjacnecy matrix
%

%% FUNCTION CODE
% Calculate the distance an agent is from every other agent
dist = pdist2(agentPosition,agentPosition); 

% Calculating the adjacency matrix
A = k*((sigma^2 + dist.^2).^beta).^-1;

end


