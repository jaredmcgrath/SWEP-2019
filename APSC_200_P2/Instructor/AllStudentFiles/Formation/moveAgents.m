function agentData = moveAgents(agentData, L,...
    iteration, timeStep)
%% moveAgents
% Move agents (and update any agent info, including enegry) whilst taking
% into account the Laplacian, time delays (tau), offsets, energy, the 
% current iteration, and time step
%
% Parameters:
%   agentData
%     n-by-6 vector of agent data before update, where:
%       column 1 is x position
%       column 2 is y position
%       column 3 is tau
%       column 4 is x offset
%       column 5 is y offset
%       column 6 is energy
%   L
%     Laplacian matrix for this iteration
%   iteration
%     Current simulation iteration
%   timeStep
%     Factor that slows down convergence
%
% Returns:
%   agentData
%     Agent positions after moving in (x,y) format
%% Your Code Below
