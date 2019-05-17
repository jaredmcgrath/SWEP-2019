function agentPositions = moveAgents(agentPositions, tau, offset, L,...
    iteration, timeStep)
%% moveAgents
% Move agents whilst taking into account the Laplacian, time delays (tau),
% offsets, the current iteration, and time step
%
% Parameters:
%   agentPositions
%     n-by-2 vector of agent positions before moving in (x,y) format
%   tau
%     n-by-1 vector of agent time delays
%   offset
%     n-by-2 vector of agent covergance offsets in (x,y) format
%   L
%     Laplacian matrix for this iteration
%   iteration
%     Current simulation iteration
%   timeStep
%     Factor that slows down convergence
%
% Returns:
%   agentPositions
%     Agent positions after moving in (x,y) format

originalPositions = agentPositions;
% Find time-delayed agents by tau
timeDelayedAgents = find(tau >= iteration);
% Update Positions
agentPositions = agentPositions - (timeStep * (L * (agentPositions - offset)));
% Revert time delayed agents to not move
agentPositions(timeDelayedAgents,:) = originalPositions(timeDelayedAgents,:);
